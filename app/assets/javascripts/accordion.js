function hookAccordion() {
    let acc = document.getElementsByClassName("accordion");
    let i;
    for (i = 0; i < acc.length; i++) {
        acc[i].addEventListener("click", function() {
            let on = this.classList.contains('active');
                this.classList.toggle("active");
            let panel = this.nextElementSibling;
            if (on) {
                panel.style.display = 'none';
            } else {
                panel.style.display = "flex";
            }
            // let sib = this.nextElementSibling;
            // sib.classList.toggle('m-fadeIn');
            // sib.classList.toggle('m-fadeOut');
        });
    }
}

