<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "localhost";
$username   = "root";
$password   = ""; // XAMPP default password
$dbname     = "food_db";

$conn = new mysqli($servername, $username, $password);

if ($conn->connect_error) {
    die(json_encode(["status" => false, "message" => "Database Connection Failed: " . $conn->connect_error]));
}

// Ensure database exists
$conn->query("CREATE DATABASE IF NOT EXISTS $dbname");
$conn->select_db($dbname);
?>
