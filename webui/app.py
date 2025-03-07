from flask import Flask, render_template, request, redirect, url_for, session
import subprocess
import os
import json
import glob

app = Flask(__name__)
app.secret_key = os.urandom(24)  # Secret key for session management

# Check for the required environment variables
env_username = os.getenv('USERNAME')
env_password = os.getenv('PASSWORD')

if not env_username or not env_password:
    print("Error: USERNAME and PASSWORD environment variables must be set.")
    sys.exit(1)

def get_accounts():
    """Get available accounts by looking at the maFiles directory"""
    accounts = []
    mafiles_dir = '/root/.config/steamguard-cli/maFiles'
    
    try:
        if not os.path.exists(mafiles_dir):
            print(f"maFiles directory not found: {mafiles_dir}")
            return []
            
        mafiles = glob.glob(os.path.join(mafiles_dir, '*.maFile'))
        print(f"Found maFiles: {mafiles}")
        
        for mafile in mafiles:
            account_name = os.path.basename(mafile).replace('.maFile', '')
            accounts.append(account_name)
            
        return accounts
    except Exception as e:
        print(f"Error finding accounts: {e}")
        return []

@app.route('/')
def index():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    accounts = get_accounts()
    print(f"Found accounts: {accounts}")
    
    code = None
    error = None
    
    try:
        print("Running: steamguard code")
        result = subprocess.run(["steamguard", "code"], capture_output=True, text=True)
        print(f"Return code: {result.returncode}, Output: {result.stdout}, Error: {result.stderr}")
        
        if result.returncode == 0:
            code = result.stdout.strip()
        else:
            error = f"Error: {result.stderr.strip()}"
    except Exception as e:
        print(f"Exception getting code: {e}")
        error = f"Exception: {str(e)}"
    
    return render_template('index.html', accounts=accounts, code=code, error=error)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # Get the credentials from environment variables or hardcode them
        expected_username = os.environ.get('USERNAME', 'admin')
        expected_password = os.environ.get('PASSWORD', 'password')

        if username == expected_username and password == expected_password:
            session['logged_in'] = True
            return redirect(url_for('index'))
        else:
            return render_template('index.html', error="Invalid credentials")
    
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
