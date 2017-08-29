osascript -e '
tell application "Terminal"
  do script "echo $DS_RUNTIME"
  activate
end tell'
