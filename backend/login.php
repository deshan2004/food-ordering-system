<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$email    = isset($data['email']) ? trim($data['email']) : '';
$password = isset($data['password']) ? trim($data['password']) : '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => false, "message" => "Please enter both email and password"]);
    exit();
}

$stmt = $conn->prepare("SELECT id, name, email, phone, password, role, address, rewardsPoints FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();
    if (password_verify($password, $row['password']) || $password === $row['password']) {
        echo json_encode([
            "status" => true,
            "message" => "Login successful!",
            "user" => [
                "id" => "usr_" . $row['id'],
                "name" => $row['name'],
                "email" => $row['email'],
                "phone" => $row['phone'] ?? '',
                "role" => $row['role'] ?? 'customer',
                "address" => $row['address'] ?? 'No. 45, Galle Road, Colombo 03',
                "rewardsPoints" => (int)($row['rewardsPoints'] ?? 200)
            ]
        ]);
    } else {
        echo json_encode(["status" => false, "message" => "Incorrect password. Please try again."]);
    }
} else {
    echo json_encode(["status" => false, "message" => "No account found with this email address."]);
}

$stmt->close();
$conn->close();
?>
