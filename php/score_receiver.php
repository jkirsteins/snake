<?php
  
$con = mysql_connect("localhost", "", "") or die(mysql_error());
$db = mysql_select_db("kirsis_snake") or die(mysql_error());

$name = mysql_real_escape_string($_POST['name']);
$score = mysql_real_escape_string($_POST['score']);
$type = mysql_real_escape_string($_POST['game_type']);

if (!(trim($name) != "" && is_numeric($score) && is_numeric($type)))
        die("Invalid values");


$result = mysql_query("INSERT INTO scores (created_at, score, name, type) VALUES (NOW(), '$score', '$name', '$type')");

if (!$result)
        die(mysql_error());


$result = mysql_query("SELECT * FROM scores WHERE type = '$type' ORDER BY score DESC LIMIT 10");
if (!$result)
        die(mysql_error());

$pos = 1;
while ($row = mysql_fetch_assoc($result))
        echo sprintf("#%d - %s - %s pts - %s\n", 
                $pos++, 
                $row['name'], 
                $row['score'], 
                $row['created_at']);

