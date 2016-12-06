<?php

if (!in_array($_SERVER['REMOTE_ADDR'], array('127.0.0.1', '::1', $_SERVER['SERVER_ADDR']))) {
  exit(1);
}

define('CACHE_DIR', __DIR__ . '/app/cache');
define('AUTOPTIMIZE', 'autoptimize');
define('WPSUPERCACHE', 'wpsc');

function isDirEmpty($dir)
{
    if (!is_readable($dir)) {
        return null;
    }
    $handle = opendir($dir);
    while (false !== ($entry = readdir($handle))) {
        if ($entry != "." && $entry != "..") {
            return false;
        }
    }
    return true;
}

function deleteDirectoryContents($dir)
{
    if (!is_dir($dir) || !is_writable($dir)) {
        return;
    }
    $structure = glob(rtrim($dir, '/') .'/*');
    if (is_array($structure)) {
        foreach ($structure as $file) {
            if (is_dir($file)) {
                deleteDirectoryContents($file);
                rmdir($file);
            } elseif (is_file($file)) {
                unlink($file);
            }
        }
    }
}

function clearCache($files) {
    if (!is_array($files)) {
        $files = [$files];
    }
    foreach ($files as $file) {
        if (file_exists($file) && !is_writable($file)) {
            echo sprintf('%s is not writable.\n', $file);
            exit(1);
        } elseif (is_dir($file) && isDirEmpty($file)) {
            echo sprintf("%s is already cleared.\n", basename($file));
        } elseif (is_file($file)) {
            unlink($file);
            echo sprintf("%s cleared.\n", basename($file));
        } elseif (is_dir($file)) {
            deleteDirectoryContents($file);
            echo sprintf("%s cleared.\n", basename($file));
        }
    }
}

function init($task)
{
    switch ($task) {
        case AUTOPTIMIZE:
            clearCache(CACHE_DIR . '/autoptimize');
            break;
        case WPSUPERCACHE:
            clearCache([
                CACHE_DIR . '/blogs',
                CACHE_DIR . '/meta',
                CACHE_DIR . '/supercache',
            ]);
            clearCache(glob(CACHE_DIR . '/wp-cache-*'));
            break;
        default:
            echo 'Command does not exist.';
            exit(127);
    }
}

$command = isset($_GET['command']) ? $_GET['command'] : null;
init($command);
