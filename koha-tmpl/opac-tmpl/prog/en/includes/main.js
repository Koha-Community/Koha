// one window.onload to rule them all

window.onload=kohajs;

// check to see if functions exist before loading them
function kohajs() {
  if ( typeof window.verify_images == "function" ) verify_images();
}

