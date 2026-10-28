<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$email          = isset($data['email']) ? trim($data['email']) : '';
$id             = isset($data['id']) ? trim($data['id']) : '';
$name           = isset($data['name']) ? trim($data['name']) : null;
$phone          = isset($data['phone']) ? trim($data['phone']) : null;
$address        = isset($data['address']) ? trim($data['address']) : null;
$avatarUrl      = isset($data['avatar_url']) ? trim($data['avatar_url']) : (isset($data['avatarUrl']) ? trim($data['avatarUrl']) : null);
$vehicleInfo    = isset($data['vehicle_info']) ? trim($data['vehicle_info']) : (isset($data['vehicleInfo']) ? trim($data['vehicleInfo']) : null);
$restaurantName = isset($data['restaurant_name']) ? trim($data['restaurant_name']) : (isset($data['restaurantName']) ? trim($data['restaurantName']) : null);

// Clean id if prefixed with usr_
if (strpos($id, 'usr_') === 0) {
    $numericId = (int)substr($id, 4);
} else {
    $numericId = (int)$id;
}

if (empty($email) && $numericId <= 0) {
    echo json_encode(["status" => false, "message" => "Email or user ID is required"]);
    exit();
}

$stmt = $conn->prepare("SELECT id, name, email, phone, role, address, rewardsPoints, avatar_url, vehicle_info, restaurant_name FROM users WHERE email = ? OR id = ?");
$stmt->bind_param("si", $email, $numericId);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
    echo json_encode(["status" => false, "message" => "User not found"]);
    $stmt->close();
    $conn->close();
    exit();
}

$existing = $res->fetch_assoc();
$targetId = $existing['id'];
$stmt->close();

$finalName           = ($name !== null && $name !== '') ? $name : $existing['name'];
$finalPhone          = ($phone !== null && $phone !== '') ? $phone : $existing['phone'];
$finalAddress        = ($address !== null && $address !== '') ? $address : $existing['address'];
$finalAvatarUrl      = ($avatarUrl !== null && $avatarUrl !== '') ? $avatarUrl : $existing['avatar_url'];
$finalVehicleInfo    = ($vehicleInfo !== null && $vehicleInfo !== '') ? $vehicleInfo : $existing['vehicle_info'];
$finalRestaurantName = ($restaurantName !== null && $restaurantName !== '') ? $restaurantName : $existing['restaurant_name'];

$updateStmt = $conn->prepare("UPDATE users SET name = ?, phone = ?, address = ?, avatar_url = ?, vehicle_info = ?, restaurant_name = ? WHERE id = ?");
$updateStmt->bind_param("ssssssi", $finalName, $finalPhone, $finalAddress, $finalAvatarUrl, $finalVehicleInfo, $finalRestaurantName, $targetId);

if ($updateStmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Profile updated successfully!",
        "user" => [
            "id" => "usr_" . $targetId,
            "name" => $finalName,
            "email" => $existing['email'],
            "phone" => $finalPhone,
            "role" => $existing['role'],
            "address" => $finalAddress,
            "rewardsPoints" => (int)($existing['rewardsPoints'] ?? 200),
            "avatarUrl" => $finalAvatarUrl,
            "vehicleInfo" => $finalVehicleInfo,
            "restaurantName" => $finalRestaurantName
        ]
    ]);
} else {
    echo json_encode(["status" => false, "message" => "Failed to update profile: " . $updateStmt->error]);
}

$updateStmt->close();
$conn->close();
?>
