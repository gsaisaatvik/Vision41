<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "sma";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get data from the form
    $name = $_POST['name'];
    $age = $_POST['age'];
    $gender = $_POST['gender'];
    $SmokerStatus = $_POST['SmokerStatus'];
    $PreExistingCondition = $_POST['PreExistingCondition'];
    $bmi = $_POST['bmi'];

    // Insert user data into the Users table
    $sql = "INSERT INTO Users (Name, Age, Gender, SmokerStatus, PreExistingCondition, BMI) 
            VALUES ('$name', '$age', '$gender', '$SmokerStatus', '$PreExistingCondition', '$bmi')";

    if ($conn->query($sql) === TRUE) {
        echo "<script>
                alert('Successfully updated your info');
                window.location.href = 'dashboard.html';
              </script>";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

$conn->close();
?>

