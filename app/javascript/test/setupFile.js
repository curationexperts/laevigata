// Add a fake csrf-token to the DOM, because our App component looks
// for one in the DOM
document.write("<meta name='csrf-token' content='THE-TOKEN'>")
