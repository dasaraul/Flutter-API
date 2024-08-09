<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$cards = [
    ["value" => "ACE", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/ace_of_hearts.png"],
    ["value" => "2", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/2_of_hearts.png"],
    ["value" => "3", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/3_of_hearts.png"],
    ["value" => "4", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/4_of_hearts.png"],
    ["value" => "5", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/5_of_hearts.png"],
    ["value" => "6", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/6_of_hearts.png"],
    ["value" => "7", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/7_of_hearts.png"],
    ["value" => "8", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/8_of_hearts.png"],
    ["value" => "9", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/9_of_hearts.png"],
    ["value" => "10", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/10_of_hearts.png"],
    ["value" => "JACK", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/jack_of_hearts.png"],
    ["value" => "QUEEN", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/queen_of_hearts.png"],
    ["value" => "KING", "suit" => "HEARTS", "image" => "https://jawanich.my.id/poker/king_of_hearts.png"]
];

shuffle($cards);

$drawn_cards = array_slice($cards, 0, 12);

echo json_encode(["cards" => $drawn_cards]);
?>
