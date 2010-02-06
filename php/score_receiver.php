<?php
  
$con = mysql_connect("localhost", "", "") or die(mysql_error());
$db = mysql_select_db("kirsis_snake") or die(mysql_error());

if (!isset($_POST['action']))
    die("No action specified");

$action = $_POST['action'];
$type = mysql_real_escape_string($_POST['game_type']);

if ($action != "fetch")
{

    $name = mysql_real_escape_string($_POST['name']);
    $score = mysql_real_escape_string($_POST['score']);

    if (!(trim($name) != "" && is_numeric($score) && is_numeric($type)))
        die("Invalid values");


    $result = mysql_query("INSERT INTO scores (created_at, score, name, type) VALUES (NOW(), '$score', '$name', '$type')");

    if (!$result)
        die(mysql_error());
}

$result = mysql_query("SELECT * FROM scores WHERE type = '$type' ORDER BY score DESC LIMIT 10");
if (!$result)
    die(mysql_error());


$positions = array();
// fill positions with default values, in case the database does not contain
// enough entries
for ($i = 1; $i <= 10; $i++)
{
    $positions[$i] = array(
                'name' => '    None',
                'score' => 0,
                'created_at' => null
            );
}

$pos = 1;
while ($row = mysql_fetch_assoc($result))
{
    $positions[$pos++] = array(
                'name' => sprintf("%-8s", $row['name']),
                'score' => $row['score'],
                'created_at' => $row['created_at']
            );
        //echo sprintf("#%d - %s - %s pts - %s\n", 
        //        $pos++, 
        //        $row['name'], 
        //        $row['score'], 
        //        $row['created_at']);
}

die(json_encode($positions));

