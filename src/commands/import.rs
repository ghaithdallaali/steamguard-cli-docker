use std::path::Path;

use log::*;

use crate::{accountmanager::ManifestAccountImportError, AccountManager};

use super::*;

#[derive(Debug, Clone, Parser, Default)]
#[clap(
	about = "Import an account with steamguard already set up. It must not be encrypted. If you haven't used steamguard-cli before, you probably don't need to use this command."
)]
pub struct ImportCommand {
	#[clap(long, help = "Paths to one or more maFiles, eg. \"./gaben.maFile\"")]
	pub files: Vec<String>,
}

impl<T> ManifestCommand<T> for ImportCommand
where
	T: Transport,
{
	fn execute(
		&self,
		_transport: T,
		manager: &mut AccountManager,
		_args: &GlobalArgs,
	) -> anyhow::Result<()> {
		for file_path in self.files.iter() {
			debug!("loading entry: {:?}", file_path);
			match manager.import_account(file_path) {
				Ok(_) => {
					info!("Imported account: {}", &file_path);
				}
				Err(ManifestAccountImportError::AlreadyExists { .. }) => {
					warn!("Account already exists: {} -- Ignoring", &file_path);
				}
				Err(ManifestAccountImportError::DeserializationFailed(orig_err)) => {
					debug!("Falling back to external account import",);

					let path = Path::new(&file_path);
					let account =
						match crate::accountmanager::migrate::load_and_upgrade_external_account(
							path,
						) {
							Ok(account) => account,
							Err(err) => {
								error!("Failed to import account: {} {}", &file_path, err);
								error!("The original error was: {}", orig_err);
								continue;
							}
						};
					manager.add_account(account);
					info!("Imported account: {}", &file_path);
				}
				Err(err) => {
					bail!("Failed to import account: {} {}", &file_path, err);
				}
			}
		}

		manager.save()?;
		Ok(())
	}
}
