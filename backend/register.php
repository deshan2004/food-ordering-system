<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$name           = isset($data['name']) ? trim($data['name']) : '';
$email          = isset($data['email']) ? trim($data['email']) : '';
$phone          = isset($data['phone']) ? trim($data['phone']) : '';
$password       = isset($data['password']) ? trim($data['password']) : '';
$role           = isset($data['role']) ? trim($data['role']) : 'customer';
$vehicleInfo    = isset($data['vehicle_info']) ? trim($data['vehicle_info']) : (isset($data['vehicleInfo']) ? trim($data['vehicleInfo']) : null);
$restaurantName = isset($data['restaurant_name']) ? trim($data['restaurant_name']) : (isset($data['restaurantName']) ? trim($data['restaurantName']) : null);
$avatarUrl      = isset($data['avatar_url']) ? trim($data['avatar_url']) : (isset($data['avatarUrl']) ? trim($data['avatarUrl']) : '');

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
$stmt = $conn->prepare("INSERT INTO users (name, email, phone, password, role, rewardsPoints, vehicle_info, restaurant_name, avatar_url) VALUES (?, ?, ?, ?, ?, 200, ?, ?, ?)");
$stmt->bind_param("ssssssss", $name, $email, $phone, $hashedPassword, $role, $vehicleInfo, $restaurantName, $avatarUrl);

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
            "role" => $role,
            "rewardsPoints" => 200,
            "address" => "No. 45, Galle Road, Colombo 03",
            "avatarUrl" => $avatarUrl,
            "vehicleInfo" => $vehicleInfo,
            "restaurantName" => $restaurantName
        ]
    ]);
} else {
    echo json_encode(["status" => false, "message" => "Registration failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
