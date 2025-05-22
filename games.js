// Full repository structure - ALL GAMES INCLUDED 
const repository = { 
    "2 yr old": [ 
        "enhanced-toddler-app.html" 
        ,"reading-game prek to grade 3 v2.html" 
        ,"WritingFitnessV4.html" 
    ], 
    "5 yr old": [ 
        "absolute-value-game.html" 
        ,"Addition Strategies.html" 
        ,"AIpathfinderV2.html" 
        ,"algebra-levels.html" 
        ,"area-volume-game.html" 
        ,"asteroidBlasterV03.html" 
        ,"battleshipv7.html" 
        ,"binomial insects game.html" 
        ,"binomial-blocks-game.html" 
        ,"BubblePop2.0..html" 
        ,"bubbleshooter v3 working.html" 
        ,"calculus-game.html" 
        ,"Circle of fifths.html" 
        ,"Combine Like Terms.html" 
        ,"compareFractions v0.2.html" 
        ,"connect4.html" 
        ,"coordinatesExplorer.html" 
        ,"decimal add and subtract v0.1.html" 
        ,"decimal multiply v0.1.html" 
        ,"Derivatives and Integrals.html" 
        ,"Distributive property greek.html" 
        ,"divisibility_rulesv_0.6.html" 
        ,"division-adventure-game.html" 
        ,"DotsGameV02.html" 
        ,"dress-up-game.html" 
        ,"drone-show-explorer.html" 
        ,"element-explorer-simplified.html" 
        ,"enhanced-division-game v3.html" 
        ,"exponent-explorer-game.html" 
        ,"exponential-growth-improved.html" 
        ,"factoring Terms.html" 
        ,"factoring-binomials-game.html" 
        ,"factoring-game.html" 
        ,"factoringPolynomialsGCF.html" 
        ,"factortree_v2.html" 
        ,"Find the area.html" 
        ,"find the coordinates.html" 
        ,"fixed-tiles-hop-game.html" 
        ,"fraction-adventure.html" 
        ,"fraction-game.html" 
        ,"fraction-safari-game.html" 
        ,"genetics-explorer-game.html" 
        ,"genius-trivia-game.html" 
        ,"geo-genius-game.html" 
        ,"geography-globe.html" 
        ,"geography-map.html" 
        ,"Guess country Globe v1.html" 
        ,"Guess country v9.html" 
        ,"Hexcells_Minesweeper.html" 
        ,"LearnExponents.html" 
        ,"learning_universe_explorer.html" 
        ,"mahjong tiles matching-game.html" 
        ,"mahjong.html" 
        ,"measurement_adventure_game.html" 
        ,"melody-hop-premium.html" 
        ,"melody-hop.html" 
        ,"MIDI music painting v2 additional features.html" 
        ,"MIDI Note analyzer V5.2.html" 
        ,"money-garden-game.html" 
        ,"Multiplication flash cards.html" 
        ,"NegativePolynomials.html" 
        ,"neural-learner-app.html" 
        ,"numberline_negatives.html" 
        ,"numberline_with_negatives.html" 
        ,"pacman-game.html" 
        ,"pattern-explorer-game.html" 
        ,"pattern-game.html" 
        ,"pemdas v0.html" 
        ,"percentagesV0.html" 
        ,"piano-waterfall.html" 
        ,"plot mx plus b v1.html" 
        ,"Reducing fractions with algebra v3.html" 
        ,"reducing fractions.html" 
        ,"rotated-blocks-game v3.html" 
        ,"scientific-notation-game with negative.html" 
        ,"scientific-notation-learn.html" 
        ,"ScientificNotationV2.html" 
        ,"Select the fraction.html" 
        ,"Short Division.html" 
        ,"simon-says-pattern-game.html" 
        ,"Simplify Like Terms.html" 
        ,"SliderPic.html" 
        ,"Snake game v2.html" 
        ,"soduku.html" 
        ,"solar_system_explorer.html" 
        ,"solitaire-game v2.html" 
        ,"space-adventure-learn.html" 
        ,"space-explorer-game.html" 
        ,"tech-explorer-game.html" 
        ,"tiles-hop-game.html" 
        ,"timer-game.html" 
        ,"trig-adventure.html" 
        ,"trinomial-factoring-game.html" 
        ,"TroubleGameV1.html" 
        ,"vector-scalar-game.html" 
        ,"water-bubble-game.html" 
        ,"Where on the numberline.html" 
        ,"word-roots.html" 
        ,"WordProblem_Mobile v0.html" 
        ,"wordscramble.html" 
        ,"Writing big numbers.html" 
        ,"zeroProperty_v2.4.html" 
    ] 
}; 
// Recently added games 
const recentlyAddedGames = [ 
    { 
        name: "decimal multiply v0.1 ", 
        icon: "fas fa-gamepad", 
        category: "games", 
        subCategory: "puzzleGames", 
        description: "Explore and learn with this interactive educational activity.", 
        path: "5 yr old/decimal multiply v0.1.html ", 
        lastUpdated: "2025-05-21" 
    }, 
    { 
        name: "decimal add and subtract v0.1 ", 
        icon: "fas fa-gamepad", 
        category: "games", 
        subCategory: "puzzleGames", 
        description: "Explore and learn with this interactive educational activity.", 
        path: "5 yr old/decimal add and subtract v0.1.html ", 
        lastUpdated: "2025-05-21" 
    }, 
    { 
        name: "factortree v2 ", 
        icon: "fas fa-gamepad", 
        category: "games", 
        subCategory: "puzzleGames", 
        description: "Explore and learn with this interactive educational activity.", 
        path: "5 yr old/factortree_v2.html ", 
        lastUpdated: "2025-05-21" 
    }, 
    { 
        name: "numberline negatives ", 
        icon: "fas fa-gamepad", 
        category: "games", 
        subCategory: "puzzleGames", 
        description: "Explore and learn with this interactive educational activity.", 
        path: "5 yr old/numberline_negatives.html ", 
        lastUpdated: "2025-05-21" 
    }, 
    { 
        name: "reducing fractions ", 
        icon: "fas fa-gamepad", 
        category: "games", 
        subCategory: "puzzleGames", 
        description: "Explore and learn with this interactive educational activity.", 
        path: "5 yr old/reducing fractions.html ", 
        lastUpdated: "2025-05-21" 
    } 
]; 
 
// DIRECT DISPLAY CODE - FORCES ALL GAMES TO DISPLAY 
document.addEventListener('DOMContentLoaded', function() { 
    console.log("Showing ALL games - 3 toddler games + 102 elementary games"); 
 
    // Force display all toddler games 
    const toddlerGrid = document.getElementById('toddlerGrid'); 
    if (toddlerGrid) { 
        toddlerGrid.innerHTML = ''; // Clear existing content 
        repository["2 yr old"].forEach(filename =
            // Simple name processing 
            let name = filename.replace(".html", "").replace(/v\d+(\.\d+)?/ig, "").replace(/V\d+(\.\d+)?/ig, ""); 
            name = name.replace(/[-_.]/g, " "); 
            name = name.split(" ").map(word = + word.slice(1)).join(" ").trim(); 
 
            // Determine icon 
            let iconClass = "fas fa-puzzle-piece"; 
            let category = "language"; 
 
            // Create card HTML 
            const cardHTML = ` 
