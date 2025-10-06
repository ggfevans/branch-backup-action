#!/bin/bash

# io.sh - Input/output operations for GitHub Actions outputs and summaries
# This library handles writing outputs and summaries

set -Eeuo pipefail

# Set GitHub Actions output variable
# Args: name value
set_output() {
    local name="$1"
    local value="$2"
    
    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        echo "$name=$value" >> "$GITHUB_OUTPUT"
    else
        echo "::set-output name=$name::$value"
    fi
}

# Write backup outputs
# Args: backup_branch backup_status commit_sha backup_date
write_backup_outputs() {
    local backup_branch="$1"
    local backup_status="$2" 
    local commit_sha="$3"
    local backup_date="$4"
    
    set_output "branch" "$backup_branch"
    set_output "status" "$backup_status"
    set_output "commit" "$commit_sha"
    set_output "date" "$backup_date"
}

# Generate backup summary for GitHub Actions step summary
# Args: backup_status backup_branch commit_sha backup_date source_branch
generate_backup_summary() {
    local backup_status="$1"
    local backup_branch="$2"
    local commit_sha="$3"
    local backup_date="$4"
    local source_branch="$5"
    
    local summary_file="${GITHUB_STEP_SUMMARY:-/dev/stdout}"
    
    {
        echo "## Weekly Backup Report"
        echo ""
        
        case "$backup_status" in
            "created")
                echo "### ✅ Backup Created Successfully"
                ;;
            "skipped")
                echo "### ⏭️ Backup Already Exists"
                ;;
            *)
                echo "### ❌ Backup Failed"
                ;;
        esac
        
        echo ""
        echo "**Details:**"
        echo "- Date: \`$backup_date\`"
        echo "- Branch: \`$backup_branch\`"
        echo "- Commit: \`$commit_sha\`"
        echo "- Source: \`$source_branch\`"
        echo ""
        echo "[View Backup Branch](https://github.com/${GITHUB_REPOSITORY:-unknown}/tree/$backup_branch)"
    } >> "$summary_file"
}

# Log message with emoji
# Args: level message
log_message() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "success")
            echo "✅ $message"
            ;;
        "skip")
            echo "⏭️ $message"
            ;;
        "error")
            echo "❌ $message" >&2
            ;;
        *)
            echo "$message"
            ;;
    esac
}