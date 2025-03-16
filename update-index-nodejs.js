const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const TODDLER_DIR = '2 yr old';
const ELEMENTARY_DIR = '5 yr old';
const INDEX_FILE = 'index.html';

// Create backup of index.html
const backupDate = new Date().toISOString().slice(0, 10).replace(/-/g, '');
const backupFileName = `${INDEX_FILE}.bak.${backupDate}`;
fs.copyFileSync(INDEX_FILE, backupFileName);
console.log(`Created backup: ${backupFileName}`);

// Function to scan directory for HTML files
function scanDirectory(directory) {
    console.log(`Scanning ${directory} directory...`);
    
    try {
        const files = fs.readdirSync(directory)
            .filter(file => file.toLowerCase().endsWith('.html'))
            .sort(); // Sort alphabetically
        
        console.log(`Found ${files.length} files in ${directory} directory`);
        return files;
    } catch (error) {
        console.error(`Error scanning ${directory}: ${error.message}`);
        return [];
    }
}

// Get HTML files from directories
const toddlerFiles = scanDirectory(TODDLER_DIR);
const elementaryFiles = scanDirectory(ELEMENTARY_DIR);

// Create repository object JavaScript code
const repositoryObjectJS = `        // Define the structure of your repository
        const repository = {
            "2 yr old": [
                ${toddlerFiles.map(file => `"${file}"`).join(',\n                ')}
            ],
            "5 yr old": [
                ${elementaryFiles.map(file => `"${file}"`).join(',\n                ')}
            ]
        };`;

// Read the current index.html file
let indexContent = fs.readFileSync(INDEX_FILE, 'utf8');

// Replace the repository object in the file
const regex = /\/\/ Define the structure of your repository[\s\S]*?\};/;
indexContent = indexContent.replace(regex, repositoryObjectJS);

// Write the updated content back to index.html
fs.writeFileSync(INDEX_FILE, indexContent);
console.log('index.html updated successfully!');

// Git operations
try {
    // Get current branch
    const currentBranch = execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
    
    console.log('Committing and pushing changes...');
    execSync('git add .');
    execSync('git commit -m "Updated index.html with repository structure"');
    execSync(`git push origin ${currentBranch}`);
    
    console.log('===== SUCCESS: CHANGES PUSHED TO GITHUB =====');
    console.log('IMPORTANT: Clear your browser cache (Ctrl+F5) to see changes!');
} catch (error) {
    console.error(`Error during git operations: ${error.message}`);
}
