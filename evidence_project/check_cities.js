import fs from 'fs';

const data = JSON.parse(fs.readFileSync('static/brazil-cities-normalized.geojson', 'utf8'));
const mapCities = data.features.map(f => f.properties.id);

console.log("Total cities in map:", mapCities.length);
console.log("Sample map cities:", mapCities.slice(0, 5));
