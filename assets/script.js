pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");

let currentScale = 1;
let pdfDoc = null;
let currentPage = 1;
let selectedPdfText = "";

function renderPage(pageNum) {
  pdfDoc.getPage(pageNum).then((page) => {
    const viewport = page.getViewport({ scale: 1.5 });
    const canvas = document.getElementById("pdf-canvas");
    const ctx = canvas.getContext("2d");

    canvas.width = viewport.width;
    canvas.height = viewport.height;

    const renderContext = {
      canvasContext: ctx,
      viewport: viewport,
    };

    page.render(renderContext).promise.then(() => {
      window.flutter_inappwebview.callHandler("loadingListener", false);
      return page.getTextContent();
    }).then((textContent) => {
      const textLayer = document.createElement("div");
      textLayer.className = "textLayer";
      textLayer.style.width = `${viewport.width}px`;
      textLayer.style.height = `${viewport.height}px`;
      document.getElementById("page-container").appendChild(textLayer);

      pdfjsLib.renderTextLayer({
        textContent: textContent,
        container: textLayer,
        viewport: viewport,
        textDivs: [],
      });
    });

    window.flutter_inappwebview.callHandler("currentPage", pageNum);
  });
}

function renderPdf(pdfBase64) {
  pdfjsLib.getDocument({ data: base64ToUint8Array(pdfBase64) }).promise.then((pdf) => {
    pdfDoc = pdf;
    renderPage(currentPage);
    window.flutter_inappwebview.callHandler("totalPdfPages", pdfDoc.numPages);
  }).catch((error) => {
    console.error("Error loading PDF:", error);
  });
}

function base64ToUint8Array(base64) {
  const raw = atob(base64);
  const uint8Array = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    uint8Array[i] = raw.charCodeAt(i);
  }
  return uint8Array;
}

function jumpToPage(pageNum) {
  if (pageNum < 1 || pageNum > pdfDoc.numPages) {
    console.error("Invalid page number:", pageNum);
    return;
  }

  if (pageNum === currentPage) {
    console.log("Already on the requested page:", pageNum);
    return;
  }

  currentPage = pageNum;
  renderPage(currentPage).catch((error) => {
    console.error("Error rendering page:", error);
  });
}

function changePage(toNextPage) {
  if (toNextPage && currentPage < pdfDoc.numPages) {
    currentPage++;
    renderPage(currentPage);
  } else if (!toNextPage && currentPage > 1) {
    currentPage--;
    renderPage(currentPage);
  }
}
