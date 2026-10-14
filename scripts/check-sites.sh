#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$0")"

# Path to the JSON file in the same directory as the script
JSON_FILE="$SCRIPT_DIR/websites.json"

# Path to the iMessage script as specified
IMESSAGE_SCRIPT="/Users/brad/GitHub/text-messages/send-imessage.sh"
PHONE_NUMBER="8584141381"

# Path to the log file
LOG_FILE="/Users/brad/logs/check-sites.log"

# Function to log messages with timestamp and log level
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $level: $message" | tee -a "$LOG_FILE"
}

# Check for test mode flag
TEST_MODE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--test)
            TEST_MODE=true
            shift
            ;;
        *)
            log_message "ERROR" "Unknown option: $1"
            exit 1
            ;;
    esac
done

# If test mode is enabled, send a sample iMessage and exit
if [[ "$TEST_MODE" = true ]]; then
    log_message "INFO" "Running in test mode: Sending sample iMessage."
    SAMPLE_URL="https://test.example.com"
    # Test mode call to send-imessage.sh
    if /bin/bash "$IMESSAGE_SCRIPT" "website is down: $SAMPLE_URL" "$PHONE_NUMBER"; then
        log_message "INFO" "Test iMessage sent successfully for $SAMPLE_URL"
    else
        log_message "ERROR" "Failed to send test iMessage for $SAMPLE_URL"
    fi
    log_message "INFO" "Test mode completed."
    exit 0
fi

# Check if jq is installed (required for JSON parsing)
if ! command -v jq &> /dev/null; then
    log_message "ERROR" "jq is not installed. Please install jq to parse JSON."
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    log_message "ERROR" "curl is not installed. Please install curl to check websites."
    exit 1
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_FILE" ]]; then
    log_message "ERROR" "JSON file not found at $JSON_FILE"
    exit 1
fi

# Check if the iMessage script exists
if [[ ! -f "$IMESSAGE_SCRIPT" ]]; then
    log_message "ERROR" "iMessage script not found at $IMESSAGE_SCRIPT"
    exit 1
fi

# ---------------------------------------------------------------------------
# Connectivity preflight: if this Mac has no internet (closed/asleep/offline),
# skip the run entirely. Otherwise every site check "fails" and a burst of false
# down-alerts fires when connectivity returns. We test general reachability
# against several always-up endpoints (NOT the monitored sites), and only
# proceed if at least one responds.
# ---------------------------------------------------------------------------
internet_up() {
    local probe
    for probe in \
        "https://www.google.com/generate_204" \
        "https://www.cloudflare.com" \
        "https://www.apple.com/library/test/success.html"; do
        # --head keeps it light; any HTTP response (even an error code) proves
        # we reached the internet. Only a connection failure counts as "down".
        if curl -s -o /dev/null -m 8 --head "$probe"; then
            return 0
        fi
    done
    return 1
}

if ! internet_up; then
    log_message "INFO" "No internet connectivity detected — skipping site checks (no alerts sent)."
    exit 0
fi

# Read URLs from JSON file (assuming JSON structure like {"websites": ["url1", "url2", ...]})
URLS=$(jq -r '.websites[]' "$JSON_FILE")

# Check if URLs were successfully read
if [[ -z "$URLS" ]]; then
    log_message "ERROR" "No URLs found in $JSON_FILE or JSON structure is invalid."
    exit 1
fi

# Check a URL, return HTTP status code
check_url() {
    local url="$1"
    curl -s -L -m 15 -o /dev/null -w "%{http_code}" "$url"
}

# Check each URL, track failures
FAILURES=0
for URL in $URLS; do
    HTTP_STATUS=$(check_url "$URL")

    # Treat 200-399 as success
    if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 400 ]]; then
        continue
    fi

    # First check failed — wait 30s and retry
    sleep 30
    HTTP_STATUS=$(check_url "$URL")

    if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 400 ]]; then
        continue
    fi

    # Confirmed down after retry
    FAILURES=$((FAILURES + 1))
    log_message "WARN" "$URL returned HTTP $HTTP_STATUS (after retry)"
    if /bin/bash "$IMESSAGE_SCRIPT" "website is down: $URL" "$PHONE_NUMBER"; then
        log_message "INFO" "iMessage sent for $URL"
    else
        log_message "ERROR" "Failed to send iMessage for $URL"
    fi
done

# Single summary line when everything is fine
if [[ "$FAILURES" -eq 0 ]]; then
    log_message "OK" "All sites up."
fi

exit 0