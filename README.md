# Hashlion: A Hashcat Automation Script

**Hashlion** is a Bash script that automates the process of selecting and running hashcat commands based on hash type, attack mode, and wordlist options. The script interacts with the user to identify the hash type, validate inputs, and then generate and run the corresponding hashcat command.

## Features

- **Hash Identification**: Supports identifying hash types using **hashid**.
- **Attack Mode Options**: Easily choose from several attack modes, such as **Straight**, **Brute-force**, **Combination**, and more.
- **Wordlist / Mask Input**: Allows the user to specify dictionaries or masks for the attack.
- **Rules File**: Optionally specify a rules file to apply during attacks.
- **Cross-platform**: Can be run on any Linux or MacOS system with Bash and hashcat installed.

## Requirements

Before running the script, make sure the following are installed:

### 1. **Hashcat**:
[Hashcat](https://hashcat.net/hashcat/) is required to perform the password cracking operations. Ensure it is installed and accessible from the command line.

### 2. **hashid**:
[hashid](https://github.com/psypanda/hashid) is a tool used to identify hash types. Install it using the following command:

```bash
pip install hashid

3. hash_modes.txt:

The script uses a hash_modes.txt file to map hash types to hashcat modes. This file must be present in the same directory as the script or you can update the script with the correct path.
Setup
1. Clone the Repository

Clone the repository to your local machine using Git:

git clone https://github.com/YOUR_USERNAME/hashlion.git
cd hashlion

2. Ensure Executable Permissions

Make sure the script is executable. Run the following command:

chmod +x hashlion.sh

3. Optional: Install Dependencies

    hashid can be installed via pip if it's not already installed:

    pip install hashid

    hashcat can be installed by following the instructions on the official website.

Usage
1. Run the Script

Run the script using the following command:

./hashlion.sh

2. Follow the Prompts

The script will prompt you for several inputs:

    Hash type number: Enter the number corresponding to the hash type. You can also use hashid to identify the hash.
    Attack Mode: Choose the attack mode (e.g., 0 for Straight, 3 for Brute-force).
    Target Hash: You can either provide a specific hash or specify a file path containing hashes.
    Wordlist or Mask: Depending on the attack mode, enter the path to your wordlist or the mask for brute-force attacks.
    Rules File: Optionally, specify a rules file to apply during the attack.

Example

Here’s an example of what a typical session might look like:

Enter a hash type number to get the associated mode:
0
Enter attack mode (e.g., 0 for Straight, 1 for Combination, 3 for Brute-force, 6 for Hybrid Wordlist + Mask, 7 for Hybrid Mask + Wordlist):
0
Enter wordlist or dictionaries (space separated if multiple):
/usr/share/wordlists/rockyou.txt
Would you like to specify a rules file? (y/n)
n
Running command: hashcat -a 0 -m 0 d3640fbc15506bfc71545e6efd31447a /usr/share/wordlists/rockyou.txt

3. Run the Command

The script will generate a hashcat command based on the inputs and execute it.
Customizing the Script

    hash_modes.txt: You can customize the hash_modes.txt file to map additional hash types to the correct hashcat modes. The format is:

    <mode_number>|<hash_name>|<hash_category>

    Default Wordlists: You can use the script with any wordlist. Modify the wordlist variable to point to your custom dictionaries.

    Mask: You can customize brute-force attack masks based on your requirements.

Troubleshooting

    hashid Not Found: If hashid is not installed, the script will attempt to run without hash identification. You can install it via pip install hashid.
    hashcat Not Found: Make sure hashcat is installed and available in your system’s $PATH.
    Invalid Hash Format: Ensure the target hash provided is in the correct format (e.g., MD5 hashes should be 32 hex characters).

License

This project is licensed under the MIT License - see the LICENSE file for details.


---

### How to Use This `README.md`:
1. **Replace** the `YOUR_USERNAME` placeholder in the `git clone` command with your actual GitHub username.
2. **Save** the content in a file named `README.md` and push it to your repository to provide users with a guide for using the script.

Let me know if you need anything else!
