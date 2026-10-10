#!/usr/bin/env bash
# Pull bradschauf.com videos/ from Bluehost to local staging, then sync to S3.
# Preserves key structure so S3 keys are videos/... (CloudFront maps /videos/* here).
# Logs to media-to-s3.log. Safe to re-run: rsync + s3 sync are incremental.
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin"
cd "$(dirname "$0")"
LOG=media-to-s3.log
: > "$LOG"
BUCKET=bradschauf-media
STAGE=staging-media/videos

echo "[$(date +%H:%M:%S)] START pull videos/ from Bluehost" >> "$LOG"
mkdir -p "$STAGE"
rsync -a --timeout=600 \
  -e "ssh -i $HOME/.ssh/schauf.priv -o ConnectTimeout=25" \
  theschau@theschaufs.com:public_html/bradschauf/videos/ "$STAGE/" >> "$LOG" 2>&1
echo "[$(date +%H:%M:%S)] pull done: $(du -sh $STAGE | cut -f1), $(find $STAGE -type f | wc -l) files" >> "$LOG"

echo "[$(date +%H:%M:%S)] START s3 sync -> s3://$BUCKET/videos/" >> "$LOG"
aws s3 sync "$STAGE/" "s3://$BUCKET/videos/" \
  --storage-class STANDARD \
  --no-progress >> "$LOG" 2>&1
echo "[$(date +%H:%M:%S)] s3 sync done" >> "$LOG"

# report what's in the bucket
echo "[$(date +%H:%M:%S)] bucket object count: $(aws s3 ls s3://$BUCKET/videos/ --recursive | wc -l)" >> "$LOG"
echo "[$(date +%H:%M:%S)] ALL DONE" >> "$LOG"
