function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function clickButtons() {
    const buttons = document.querySelectorAll('.button.subscribe');
    for (let i = 0; i < buttons.length; i++) {
        if (buttons[i].className === 'button subscribe' && buttons[i].offsetParent !== null) {
            // Comprueba si el botón tiene exactamente la clase 'button subscribe' y es visible
            buttons[i].click();
            console.log('Clicked button ' + (i + 1));
            await sleep(1000);
        }
    }
}

clickButtons();
