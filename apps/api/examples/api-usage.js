// Example usage of the News API Service
// Run with: node examples/api-usage.js

const BASE_URL = 'http://localhost:3000/api/news';

async function testAPI() {
  console.log('🚀 Testing News API Service\n');

  try {
    // Test health check
    console.log('1. Health Check:');
    const healthResponse = await fetch(`${BASE_URL}/health`);
    const healthData = await healthResponse.json();
    console.log(JSON.stringify(healthData, null, 2));
    console.log('\n');

    // Test top headlines
    console.log('2. Top Headlines (US, 2 articles):');
    const headlinesResponse = await fetch(`${BASE_URL}/top-headlines?country=us&pageSize=2`);
    const headlinesData = await headlinesResponse.json();
    console.log(`Status: ${headlinesData.success}`);
    console.log(`Total Results: ${headlinesData.data.totalResults}`);
    console.log(`Articles: ${headlinesData.data.articles.length}`);
    console.log('\n');

    // Test search
    console.log('3. Search for "technology" (1 article):');
    const searchResponse = await fetch(`${BASE_URL}/search?q=technology&pageSize=1`);
    const searchData = await searchResponse.json();
    console.log(`Status: ${searchData.success}`);
    console.log(`Total Results: ${searchData.data.totalResults}`);
    console.log(`Articles: ${searchData.data.articles.length}`);
    console.log('\n');

    // Test error handling
    console.log('4. Error Handling (missing query parameter):');
    const errorResponse = await fetch(`${BASE_URL}/search`);
    const errorData = await errorResponse.json();
    console.log(JSON.stringify(errorData, null, 2));

  } catch (error) {
    console.error('Error testing API:', error.message);
  }
}

// Run the test if this file is executed directly
if (require.main === module) {
  testAPI();
}

module.exports = { testAPI };