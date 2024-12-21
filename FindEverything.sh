#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

# Logo function
print_logo() {
    echo '    _______           ______  _____       ____        __ '
    echo '   / ____(_)___  ____/ / __ \/ ___/      / __ \__  __/ /_'
    echo '  / /_  / / __ \/ __  / / / /\__ \______/ / / / / / / __/'
    echo ' / __/ / / / / / /_/ / /_/ /___/ /_____/ /_/ / /_/ / /_  '
    echo '/_/   /_/_/ /_/\__,_/\____//____/      \____/\__,_/\__/  '
    echo
}

# Help function
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -n, --name      Specify the file extensions (comma separated)"
    echo "  -c, --content   Specify the content to search for"
    echo "  -o, --output    Specify output file (default: findout.txt)"
    echo "  -d, --directory Target directory (default: ./)"
    echo
    echo "Example:"
    echo "  $0 -n .txt,.log -c \"password\" -o results.txt -d /path/to/search"
}

# Initialize variables with default values
output_file="findout.txt"
directory="./"
extensions=""
content=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            extensions="$2"
            shift 2
            ;;
        -c|--content)
            content="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -d|--directory)
            directory="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check required parameters
if [ -z "$extensions" ] || [ -z "$content" ]; then
    echo -e "${RED}Error: Missing required parameters${NC}"
    show_help
    exit 1
fi

# Convert extensions string to array
IFS=',' read -ra ext_array <<< "$extensions"

# Clear output file
> "$output_file"

# Main search function
search_files() {
    local dir="$1"
    local search_content="$2"
    
    # Create find command with multiple extensions
    find_cmd="find \"$dir\" -type f"
    for ext in "${ext_array[@]}"; do
        find_cmd="$find_cmd -o -name \"*$ext\""
    done
    
    # Execute find command and process each file
    while IFS= read -r file; do
        echo -e "${YELLOW}Searching in: $file${NC}"
        
        # Search content in file and write results
        if grep -n "$search_content" "$file" > /dev/null 2>&1; then
            {
                echo -e "[+] File Path: $file"
                line_count=$(grep -c "$search_content" "$file")
                echo "[=] Line Rows: $line_count"
                grep -n "$search_content" "$file" | while IFS=: read -r line_num line; do
                    echo "[~] In Line $line_num: $line"
                done
                echo
            } >> "$output_file"
        fi
    done < <(eval "$find_cmd")
}

# Main execution
print_logo
echo -e "${GREEN}[+] Running Search..${NC}"
search_files "$directory" "$content"
echo -e "${GREEN}[+] Results written to $output_file${NC}"
