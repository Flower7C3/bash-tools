<?php

$sourceFileName = $argv[1];
$destinationFileName = $sourceFileName . '.btxt';
$group = [];
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
$file = fopen($sourceFileName, "r");
$groupNotesAmount = 0;
while (!feof($file)) {
    $lineData = trim(fgets($file));
    if (preg_match("'#'", $lineData)) {
        continue;
    }
    if (empty($lineData)) {
        foreach ($octaves as $octave => $octaveData) {
            if (isset($group[$octave])) {
                $octaves[$octave] .= $group[$octave];
            } else {
                $octaves[$octave] .= str_repeat('-', $groupNotesAmount);
            }
        }
        $group = [];
        $groupNotesAmount = 0;
    } else {
        $lineNo = $lineData[0];
        $lineData = substr($lineData, 1);
        $lineData = trim($lineData, '|');
        $group[$lineNo] = $lineData;
        $groupNotesAmount = strlen($lineData);
    }
}
fclose($file);

echo 'Parsing octaves to track...' . PHP_EOL;
$track = [];
foreach ($octaves as $octave => $octaveData) {
    $newOctaveData = [];
    foreach (str_split($octaveData) as $pos => $note) {
        $value = ['l' => 1, 'o' => $octave, 'n' => $note];
        if ($note === '-') {
            $value = ['l' => 1, 'o' => '0', 'n' => 'p'];
        }
        $newOctaveData[$pos] = $value;
        if (empty($track[$pos]) || $track[$pos]['n'] === 'p') {
            $track[$pos] = $value;
        }
    }
    $octaves[$octave] = $newOctaveData;
}

echo 'Increase notes...' . PHP_EOL;
$track = array_values($track);
foreach ($track as $pos => $value) {
    if ($value['n'] === 'p') {
        $prevValue = $track[$pos - 1];
        $prevValueLength = $prevValue['l'];
        $prevValueLength++;
        $prevValue['l'] = $prevValueLength;
        $track[$pos] = $prevValue;
        unset($track[$pos - 1]);
    }
}

//echo 'Removing extra pauses...' . PHP_EOL;
//foreach ($track as $pos => $value) {
//    $track[$pos]['l'] = $value['l']/2;
//}
//
echo 'Normalize...' . PHP_EOL;
foreach ($track as $pos => $value) {
    $track[$pos] = $value['n'] . $value['o'] . ',' . $value['l'];
}

echo 'Save to "' . $destinationFileName . '" file...' . PHP_EOL;
file_put_contents($destinationFileName, implode(' ', $track));