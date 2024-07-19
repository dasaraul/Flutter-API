<?php
header('Content-Type: application/json');

$cards = [
    ["value" => "ACE", "suit" => "HEARTS", "image" => "https://path/to/ace_of_hearts.png"],
    ["value" => "2", "suit" => "HEARTS", "image" => "https://path/to/2_of_hearts.png"],
    ["value" => "3", "suit" => "HEARTS", "image" => "https://path/to/3_of_hearts.png"],
    // Tambahkan kartu lainnya sesuai kebutuhan
];

// Mengacak kartu
shuffle($cards);

// Mengambil 12 kartu pertama
$drawn_cards = array_slice($cards, 0, 12);

echo json_encode(["cards" => $drawn_cards]);
?>
