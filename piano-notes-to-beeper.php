<?php

$sourceFileName = $argv[1];
$destinationFileName = $sourceFileName . '.btxt';
$line = [];
$octaves = [
    1 => '',
    2 => '',
    3 => '',
    4 => '',
    5 => '',
    6 => '',
    7 => '',
    8 => '',
];

echo 'Reading "' . $sourceFileName . '" file...' . PHP_EOL;
$fileHandle = fopen($sourceFileName, 'rb');
$lineNotesAmount = 0;
while (!feof($fileHandle)) {
    $row = trim(fgets($fileHandle));
    if (preg_match("'#'", $row)) {
        continue;
    }
    if (empty($row)) {
        foreach ($octaves as $octaveNo => $octaveData) {
            if (isset($line[$octaveNo])) {
                $octaves[$octaveNo] .= $line[$octaveNo];
            } else {
                $octaves[$octaveNo] .= str_repeat('-', $lineNotesAmount);
            }
        }
        $line = [];
        $lineNotesAmount = 0;
    } else {
        $octaveNo = $row[0];
        $row = substr($row, 1);
        $row = trim($row, '|');
        $line[$octaveNo] = $row;
        $lineNotesAmount = strlen($row);
    }
}
fclose($fileHandle);

echo 'Parsing octaves to track...' . PHP_EOL;
$track = [];
foreach ($octaves as $octaveNo => $octaveData) {
    $newOctaveData = [];
    foreach (str_split($octaveData) as $pos => $note) {
        $value = ['l' => 1, 'o' => $octaveNo, 'n' => $note];
        if ($note === '-') {
            $value = ['l' => 1, 'o' => '0', 'n' => '-'];
        }
        $newOctaveData[$pos] = $value;
        if (empty($track[$pos]) || $track[$pos]['n'] === '-') {
            $track[$pos] = $value;
        }
    }
}

echo 'Increase notes...' . PHP_EOL;
$track = array_values($track);
foreach ($track as $pos => $value) {
    if ($value['n'] === '-') {
        $prevValue = $track[$pos - 1];
        $prevValueLength = $prevValue['l'];
        $prevValueLength++;
        $prevValue['l'] = $prevValueLength;
        $track[$pos] = $prevValue;
        unset($track[$pos - 1]);
    }
}

echo 'Normalize...' . PHP_EOL;
foreach ($track as $pos => $value) {
    $track[$pos] = $value['n'] . $value['o'] . ',' . $value['l'];
}

echo 'Save to "' . $destinationFileName . '" file...' . PHP_EOL;
file_put_contents($destinationFileName, implode(' ', $track));