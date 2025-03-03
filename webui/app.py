from flask import Flask, render_template, request, redirect, url_for, jsonify
import subprocess
import os
import json
import glob

app = Flask(__name__)

def get_accounts():
    """Get available accounts by looking at the maFiles directory"""
    accounts = []
    mafiles_dir = '/root/.config/steamguard-cli/maFiles'
    
    try:
        # Check if maFiles directory exists
        if not os.path.exists(mafiles_dir):
            print(f"maFiles directory not found: {mafiles_dir}")
            return []
            
        # Look for .maFile files
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
    accounts = get_accounts()
    print(f"Found accounts: {accounts}")
    
    code = None
    error = None
    
    try:
        # Just run the code command without any account parameter
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)