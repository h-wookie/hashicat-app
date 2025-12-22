#!/bin/bash
# Copyright (c) HashiCorp, Inc.

# Script to deploy a simple Robot Catcher web game.
# This script generates index.html with embedded CSS/JS.

# Define output path
OUTPUT_FILE="/var/www/html/index.html"

# Write the Game HTML to the file
cat << 'EOM' > ${OUTPUT_FILE}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Robot Catcher!</title>
    <style>
        body { font-family: 'Courier New', Courier, monospace; text-align: center; background-color: #f0f0f0; }
        #game-area {
            width: 800px; height: 500px;
            margin: 20px auto; border: 3px solid #333;
            background-color: white; position: relative; overflow: hidden;
            cursor: crosshair;
        }
        .robot { position: absolute; width: 60px; height: 60px; transition: all 0.2s; user-select: none; }
        h2 { color: #333; }
        .stats { font-size: 1.2em; margin-bottom: 10px; }
        button { padding: 10px 20px; font-size: 1em; cursor: pointer; background: #333; color: white; border: none; }
    </style>
</head>
<body>

    <h2>🤖 ${PREFIX}'s Robot Catcher 🤖</h2>
    <div class="stats">Score: <span id="score">0</span> | Time: <span id="time">30</span>s</div>
    
    <div id="game-area">
        <div id="start-screen" style="padding-top: 200px;">
            <button onclick="startGame()">Start Game</button>
        </div>
    </div>

    <script>
        let score = 0;
        let timeLeft = 30;
        let gameInterval;
        let spawnInterval;
        const gameArea = document.getElementById('game-area');
        const scoreEl = document.getElementById('score');
        const timeEl = document.getElementById('time');
        
        // Terraform Variable Injection (If needed, handled by templatefile or sed later, here using JS default)
        const robotBaseUrl = "https://robohash.org/"; 

        function startGame() {
            score = 0;
            timeLeft = 30;
            scoreEl.innerText = score;
            timeEl.innerText = timeLeft;
            document.getElementById('start-screen').style.display = 'none';
            
            // Timer
            gameInterval = setInterval(() => {
                timeLeft--;
                timeEl.innerText = timeLeft;
                if(timeLeft <= 0) endGame();
            }, 1000);

            // Spawn Robots
            spawnInterval = setInterval(spawnRobot, 600);
        }

        function spawnRobot() {
            const robot = document.createElement('img');
            // Generate random robot avatar
            const randomId = Math.floor(Math.random() * 1000);
            robot.src = robotBaseUrl + randomId + "?set=set1&size=60x60";
            robot.className = 'robot';
            
            // Random Position
            const maxLeft = 740; // 800 - 60
            const maxTop = 440;  // 500 - 60
            robot.style.left = Math.floor(Math.random() * maxLeft) + 'px';
            robot.style.top = Math.floor(Math.random() * maxTop) + 'px';

            // Click Event
            robot.onclick = function() {
                score++;
                scoreEl.innerText = score;
                this.remove(); // Remove robot on click
            };

            gameArea.appendChild(robot);

            // Auto remove after 2 seconds to keep it clean
            setTimeout(() => { if(robot.parentNode) robot.remove(); }, 2000);
        }

        function endGame() {
            clearInterval(gameInterval);
            clearInterval(spawnInterval);
            alert("Game Over! Your Score: " + score);
            // Clear board
            gameArea.innerHTML = '<div id="start-screen" style="padding-top: 200px;"><button onclick="startGame()">Play Again</button></div>';
        }
    </script>
</body>
</html>
EOM

# Inject Terraform variables dynamically using sed (Best practice for Bash injection)
# Assuming ${PREFIX} is an environment variable passed by Terraform
if [ -z "$PREFIX" ]; then PREFIX="Player"; fi
sed -i "s/\${PREFIX}/$PREFIX/g" ${OUTPUT_FILE}

echo "Game deployed successfully."