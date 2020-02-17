<?php

echo 'Configure...' . PHP_EOL;
$sourceFileName = $argv[1];
$destinationFileName = $sourceFileName . '.btxt';
$line = [];
$numberOfOctaves = 8;
$octaves = [];
for ($octaveNo = $numberOfOctaves; $octaveNo >= 1; $octaveNo--) {
    $octaves[$octaveNo] = '';
}

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

echo 'Cleanup empty octaves and octave lines...' . PHP_EOL;
foreach ($octaves as $octaveNo => $octaveValue) {
    if (preg_match("'^([-]+)$'", $octaveValue)) {
        unset($octaves[$octaveNo]);
    }
}

echo 'Parsing octaves to track...' . PHP_EOL;
$track = [];
foreach ($octaves as $octaveNo => $octaveValue) {
    foreach (str_split($octaveValue) as $pos => $note) {
        $value = ['l' => 1, 'o' => $octaveNo, 'n' => $note,];
        if (empty($track[$pos]) || $track[$pos]['n'] === '-') {
            $track[$pos] = $value;
        }
    }
}

echo 'Increase notes...' . PHP_EOL;
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
$trackFinal = [];
foreach ($track as $pos => $value) {
    $trackFinal[$pos] = $value['n'] . $value['o'] . ',' . $value['l'];
}

echo 'Save to "' . $destinationFileName . '" file...' . PHP_EOL;
file_put_contents($destinationFileName, implode(' ', $trackFinal));