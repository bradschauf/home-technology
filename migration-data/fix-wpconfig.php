<?php
// Repair/set DB_PASSWORD in each wp-config.php. Runs ON the server.
// Reads pairs from argv: path=pass path=pass ...
// If the DB_PASSWORD define is missing (was clobbered), re-insert it right
// after the DB_USER define.
foreach (array_slice($argv, 1) as $pair) {
    [$file, $pass] = explode('=', $pair, 2);
    if (!is_file($file)) { echo "$file: MISSING\n"; continue; }
    $c = file_get_contents($file);
    $def = "define('DB_PASSWORD', '" . $pass . "');";
    if (preg_match("/define\(\s*['\"]DB_PASSWORD['\"]\s*,/", $c)) {
        // replace existing (possibly broken) line value
        $c = preg_replace(
            "/define\(\s*['\"]DB_PASSWORD['\"]\s*,.*?\);/s",
            $def, $c, 1, $n);
        $action = "replaced($n)";
    } else {
        // re-insert after DB_USER define
        $c = preg_replace(
            "/(define\(\s*['\"]DB_USER['\"]\s*,.*?\);)/s",
            "$1\n$def", $c, 1, $n);
        $action = "reinserted($n)";
    }
    file_put_contents($file, $c);
    // verify
    $ok = preg_match("/define\(\s*['\"]DB_PASSWORD['\"]\s*,\s*['\"]" . preg_quote($pass,'/') . "['\"]\s*\)/", $c);
    echo basename(dirname($file)) . ": $action verify=" . ($ok?"OK":"FAIL") . "\n";
}
