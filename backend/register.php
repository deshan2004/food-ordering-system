<?php
require_once 'db.php';

// Auto-create users table if not exists
$conn->query("CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255) DEFAULT 'No. 45, Galle Road, Colombo 03',
    rewardsPoints INT DEFAULT 200,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");

$data = json_decode(file_get_contents("php://input"), true);

$name     = isset($data['name']) ? trim($data['name']) : '';
$email    = isset($data['email']) ? trim($data['email']) : '';
$phone    = isset($data['phone']) ? trim($data['phone']) : '';
$password = isset($data['password']) ? trim($data['password']) : '';

if (empty($name) || empty($email) || empty($password)) {
    echo json_encode(["status" => false, "message" => "Please fill in all required fields"]);
    exit();
}

// Check if email already exists
$checkStmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkStmt->bind_param("s", $email);
$checkStmt->execute();
$checkResult = $checkStmt->get_result();

if ($checkResult->num_rows > 0) {
    echo json_encode(["status" => false, "message" => "This email is already registered! Please login."]);
    $checkStmt->close();
    $conn->close();
    exit();
}
$checkStmt->close();

// Insert new user
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);
$stmt = $conn->prepare("INSERT INTO users (name, email, phone, password, rewardsPoints) VALUES (?, ?, ?, ?, 200)");
$stmt->bind_param("ssss", $name, $email, $phone, $hashedPassword);

if ($stmt->execute()) {
    $userId = $stmt->insert_id;
    echo json_encode([
        "status" => true,
        "message" => "Registration successful!",
        "user" => [
            "id" => "usr_" . $userId,
            "name" => $name,
            "email" => $email,
            "phone" => $phone,
            "rewardsPoints" => 200,
            "address" => "No. 45, Galle Road, Colombo 03"
        ]
    ]);
} else {
    echo json_encode(["status" => false, "message" => "Registration failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
