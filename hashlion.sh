#!/bin/bash

# Declare the associative array for modes
declare -A modes

# Function to parse hash_modes.txt and populate the associative array
hash_types() {
    local file="hash_modes.txt"

    # Ensure the file exists before proceeding
    if [[ ! -f "$file" ]]; then
        echo "Error: '$file' not found."
        exit 1
    fi

    # Read the file line by line
    while IFS= read -r line; do
        # Use pipe '|' as delimiter, split the line by pipe
        IFS='|' read -r mode_number hash_name _ <<< "$line"

        # Trim leading/trailing whitespace from mode_number and hash_name
        mode_number=$(echo "$mode_number" | xargs)
        hash_name=$(echo "$hash_name" | xargs)

        # Ensure that both mode number and hash name are present before adding to array
        if [[ -n "$mode_number" && -n "$hash_name" ]]; then
            modes["$mode_number"]="$hash_name"
        fi
    done < "$file"
}

# Function to check if hashid is installed
check_hashid_installed() {
    if command -v hashid &> /dev/null; then
        return 0  # hashid is installed
    else
        return 1  # hashid is not installed
    fi
}

# Function to parse hashid output and extract hash types
parse_hashid_output() {
    local hashid_output="$1"
    local detected_hashes=()

    # Extract hash types by parsing between "]" and the last character of each line
    while IFS= read -r line; do
        # Remove the leading text before "]"
        hash_type=$(echo "$line" | sed 's/.*]//')

        # Remove trailing whitespace and characters
        hash_type=$(echo "$hash_type" | sed 's/.$//')

        # Add the detected hash type to the list if it's non-empty
        if [[ -n "$hash_type" ]]; then
            detected_hashes+=("$hash_type")
        fi
    done <<< "$hashid_output"

    echo "${detected_hashes[@]}"
}

# Call the function to populate the modes array
hash_types

# Prompt user for a hash type number
echo "Enter a hash type number to get the associated mode:"
read -r user_input

# Validate hash type input
if [[ ! "${modes[$user_input]}" ]]; then
    echo "Error: Invalid hash type number entered."

    # Check if hashid is installed
    if check_hashid_installed; then
        # Prompt user to use hashid to identify the hash
        echo "Would you like to use hashid to identify the hash? (y/n)"
        read -r use_hashid

        if [[ "$use_hashid" =~ ^[Yy]$ ]]; then
            # Prompt user to enter the unknown hash
            echo "Enter the hash to identify:"
            read -r unknown_hash

            # Save the target hash from the user input
            target="$unknown_hash"

            # Use hashid to identify the hash
            hashid_output=$(hashid "$unknown_hash")
            
            # Parse hashid output to extract detected hash types
            detected_hashes=($(parse_hashid_output "$hashid_output"))

            if [[ ${#detected_hashes[@]} -gt 0 ]]; then
                echo "Detected hash types: ${detected_hashes[@]}"
                # Check if any of the detected hash types match the ones in hash_modes.txt
                for hash_type in "${detected_hashes[@]}"; do
                    # Look for the hash type in the modes array and print the associated mode number
                    for mode in "${!modes[@]}"; do
                        if [[ "${modes[$mode]}" == "$hash_type" ]]; then
                            echo "Mode for $hash_type: $mode"
                        fi
                    done
                done
            else
                echo "No hash types detected by hashid."
            fi
        else
            echo "Exiting. No hashid identification performed."
        fi
    else
        echo "hashid is not installed. Please install hashid to identify hashes."
    fi
else
    # Set target hash directly from user input if it's valid
    target="$user_input"
fi

# Prompt user for attack mode
echo "Enter attack mode (e.g., 0 for Straight, 1 for Combination, 3 for Brute-force, 6 for Hybrid Wordlist + Mask, 7 for Hybrid Mask + Wordlist):"
read -r attack_mode

# Validate attack mode
if ! [[ "$attack_mode" =~ ^[0-9]+$ ]]; then
    echo "Invalid attack mode entered. Exiting."
    exit 1
fi

# Ask for the target hash or file path (this was missing before!)
echo "Enter the target hash (or file path):"
read -r target

# Check if the target hash is valid
if [[ ! "$target" =~ ^[a-fA-F0-9]{32}$ ]]; then
    echo "Invalid hash format. Exiting."
    exit 1
fi

# Ask for wordlist or mask depending on attack mode
case "$attack_mode" in
    0)  # Wordlist attack
        echo "Enter wordlist or dictionaries (space separated if multiple):"
        read -r wordlist
        ;;
    1)  # Combination attack (two dictionaries)
        echo "Enter the first dictionary:"
        read -r dict1
        echo "Enter the second dictionary:"
        read -r dict2
        ;;
    3)  # Brute-force attack (mask)
        echo "Enter the brute-force mask (e.g., ?l?l?l?l for 4 lowercase letters):"
        read -r mask
        ;;
    6)  # Hybrid Wordlist + Mask attack
        echo "Enter wordlist:"
        read -r wordlist
        echo "Enter mask (e.g., ?d?d?d?d for 4 digits):"
        read -r mask
        ;;
    7)  # Hybrid Mask + Wordlist attack
        echo "Enter mask (e.g., ?d?d?d?d for 4 digits):"
        read -r mask
        echo "Enter wordlist:"
        read -r wordlist
        ;;
    9)  # Association attack (requires additional setup)
        echo "Association attack is complex and requires additional setup. Exiting."
        exit 1
        ;;
    *)
        echo "Invalid attack mode. Exiting."
        exit 1
        ;;
esac

# Prompt user for a rules file (optional)
echo "Would you like to specify a rules file? (y/n)"
read -r use_rules

# If user wants to use a rules file, prompt for the file path
if [[ "$use_rules" =~ ^[Yy]$ ]]; then
    echo "Enter the path to the rules file:"
    read -r rules_file
    rules_option="-r $rules_file"
else
    rules_option=""
fi

# Construct the hashcat command based on the inputs
if [[ "$attack_mode" -eq 1 ]]; then
    # Combination attack: two dictionaries
    hashcat_command="hashcat -a $attack_mode -m $user_input $target $dict1 $dict2 $rules_option"
elif [[ "$attack_mode" -eq 3 ]]; then
    # Brute-force attack: mask
    hashcat_command="hashcat -a $attack_mode -m $user_input $target $mask $rules_option"
elif [[ "$attack_mode" -eq 6 ]]; then
    # Hybrid Wordlist + Mask attack
    hashcat_command="hashcat -a $attack_mode -m $user_input $target $wordlist $mask $rules_option"
elif [[ "$attack_mode" -eq 7 ]]; then
    # Hybrid Mask + Wordlist attack
    hashcat_command="hashcat -a $attack_mode -m $user_input $target $mask $wordlist $rules_option"
else
    # Straight attack or any other valid attack mode
    hashcat_command="hashcat -a $attack_mode -m $user_input $target $wordlist $rules_option"
fi

# Output the final command and run it
echo "Running command: $hashcat_command"
$hashcat_command
