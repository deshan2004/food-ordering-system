<?php
require_once 'db.php';

// 1. Users Table
$sqlUsers = "CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255) DEFAULT 'No. 45, Galle Road, Colombo 03',
    rewardsPoints INT DEFAULT 200,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
$conn->query($sqlUsers);

// 2. Food Items Table
$sqlFoodItems = "CREATE TABLE IF NOT EXISTS food_items (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sinhalaName VARCHAR(255),
    restaurantName VARCHAR(255) NOT NULL,
    restaurantSubtitle VARCHAR(255),
    description TEXT,
    priceLkr DECIMAL(10, 2) NOT NULL,
    rating DECIMAL(3, 1) DEFAULT 5.0,
    reviewCountText VARCHAR(50),
    deliveryTime VARCHAR(50),
    deliveryFeeLkr DECIMAL(10, 2) DEFAULT 0.00,
    category VARCHAR(100),
    imageUrl TEXT,
    isOpenNow TINYINT(1) DEFAULT 1,
    isBestseller TINYINT(1) DEFAULT 0,
    isSpecial TINYINT(1) DEFAULT 0,
    isHalal TINYINT(1) DEFAULT 1,
    servesText VARCHAR(100),
    signatureTag VARCHAR(100),
    signatureItemName VARCHAR(255),
    signatureItemPriceLkr DECIMAL(10, 2) DEFAULT 0.00
)";
$conn->query($sqlFoodItems);

// 3. Orders Table
$sqlOrders = "CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    total_amount DECIMAL(10, 2) NOT NULL,
    delivery_address TEXT,
    payment_method VARCHAR(50),
    status VARCHAR(50) DEFAULT 'Preparing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
$conn->query($sqlOrders);

// 4. Order Items Table
$sqlOrderItems = "CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    food_id VARCHAR(50),
    food_name VARCHAR(255),
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
)";
$conn->query($sqlOrderItems);

// Insert Sample Food Items if table is empty
$checkCount = $conn->query("SELECT COUNT(*) as total FROM food_items");
$rowCount = $checkCount->fetch_assoc()['total'];

if ($rowCount == 0) {
    $sqlInsert = "INSERT INTO food_items (id, name, sinhalaName, restaurantName, restaurantSubtitle, description, priceLkr, rating, reviewCountText, deliveryTime, deliveryFeeLkr, category, imageUrl, isOpenNow, isBestseller, isSpecial, isHalal, servesText, signatureTag, signatureItemName, signatureItemPriceLkr) 
    VALUES 
    ('b1', 'Chicken Cheese Kottu', 'චිකන් චීස් කොත්තු', 'Pilawaos Grand Hotel', 'Sri Lankan • Kottu & Roti • Halal • Late Night', 'Chopped godamba roti tossed on hot griddle with spiced tender roast chicken, farm-fresh eggs, leeks, carrots, rich curry gravy, and crowned with bubbling melted mozzarella cheese.', 2100.00, 4.9, '3.2k+', '20-25 min', 150.00, 'Kottu Mania', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80', 1, 1, 1, 1, 'Serves 1–2 • 650g', 'SIGNATURE HIT', 'Chicken Cheese Kottu', 1250.00),
    ('b2', 'Claypot Red Rice Feast', 'මැටි වළං රතු බත් සමග මාලු', 'Upalis by Nawaloka', 'Traditional Rice & Curry • Village Style • Seafood', 'Steaming organic red kakulu rice served in authentic claypot with Jaffna crab curry, pol sambol, fried dried fish, brinjal moju, and gotukola sambol.', 2450.00, 4.8, '2.1k+', '30-35 min', 180.00, 'Rice & Curry', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80', 1, 1, 0, 1, 'Serves 2 • 800g', 'VILLAGE SPECIAL', 'Claypot Red Rice Feast', 950.00),
    ('b3', 'Spicy Mutton Roll (Box of 4)', 'සැර එළුමස් රෝල්ස්', 'Sponge Pastry Shop', 'Short Eats • Bakery • Patties & Rolls • Snacks', 'Golden crispy crumbed rolls filled with slow-cooked shredded devilled mutton, potatoes, and Sri Lankan black pepper spices.', 1200.00, 4.7, '1.8k+', '15-20 min', 120.00, 'Short Eats', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80', 1, 0, 0, 1, 'Box of 4 Rolls', 'TEA TIME CRAVING', 'Spicy Mutton Roll (Box of 4)', 880.00)";
    $conn->query($sqlInsert);
}

echo json_encode([
    "status" => true,
    "message" => "Database & Tables created successfully in MySQL!"
]);

$conn->close();
?>
