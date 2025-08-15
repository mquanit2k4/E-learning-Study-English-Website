$(document).ready(function() {
  const selectedWordIdsData = $("#new_lesson").data("selected-word-ids");
  const initialSelectedWordIds = selectedWordIdsData ? JSON.parse(selectedWordIdsData) : [];

  const selectedWords = new Set(initialSelectedWordIds.map(id => parseInt(id, 10)));
  const selectedWordsContainer = $("#selected-words-list");
  const searchResultsContainer = $("#search-results-container");
  const wordSearchInput = $("#word_search");

  const selectedTestIdsData = $("#new_lesson").data("selected-test-ids");
  const initialSelectedTestIds = selectedTestIdsData ? JSON.parse(selectedTestIdsData) : [];

  const selectedTests = new Set(initialSelectedTestIds.map(id => parseInt(id, 10)));
  const selectedTestsContainer = $("#selected-tests-list");
  const testSearchResultsContainer = $("#test-search-results-container");
  const testSearchInput = $("#test_search");

  const selectedParagraphsContainer = $("#selected-paragraphs-list");

  function updateOrder() {
    selectedWordsContainer.find(".word-item").each(function(index) {
      $(this).find(".order-number").text(index + 1);
    });

    selectedTestsContainer.find(".test-item").each(function(index) {
      $(this).find(".order-number").text(index + 1);
    });

    selectedParagraphsContainer.find(".paragraph-item").each(function(index) {
      $(this).find(".order-number").text(index + 1);
    });
  }

  wordSearchInput.on("input", function() {
    const query = $(this).val();
    if (query.length > 2) {
      $.ajax({
        url: "/api/v1/words/search",
        data: { query: query, locale: $("body").data("locale") },
        success: function(words) {
          searchResultsContainer.empty();
          words.forEach(word => {
            if (!selectedWords.has(word.id)) {
              searchResultsContainer.append(
                `<div class="search-result-item" data-word-id="${word.id}">
                   ${word.content}
                 </div>`
              );
            }
          });
        }
      });
    } else {
      searchResultsContainer.empty();
    }
  });

  searchResultsContainer.on("click", ".search-result-item", function() {
    const wordId = $(this).data("word-id");
    const wordContent = $(this).text().trim();

    selectedWords.add(parseInt(wordId, 10));

    const newItem = `
      <div class="word-item" data-word-id="${wordId}">
        <div class="order-number"></div>
        <input type="hidden" name="lesson[word_ids][]" value="${wordId}" />
        <input type="text" value="${wordContent}" class="form-control" disabled />
        <button type="button" class="remove-word-btn" data-action="click->lessons-form#removeWord">
          <i class="fa fa-trash"></i>
        </button>
      </div>`;

    selectedWordsContainer.append(newItem);
    updateOrder();

    wordSearchInput.val("");
    searchResultsContainer.empty();
  });

  selectedWordsContainer.on("click", ".remove-word-btn", function() {
    const wordItem = $(this).closest(".word-item");
    const wordId = wordItem.data("word-id");

    selectedWords.delete(parseInt(wordId, 10));
    wordItem.remove();
    updateOrder();
  });

  testSearchInput.on("input", function() {
    const query = $(this).val();
    if (query.length > 2) {
      $.ajax({
        url: "/api/v1/tests/search",
        data: { query: query, locale: $("body").data("locale") },
        success: function(tests) {
          testSearchResultsContainer.empty();
          tests.forEach(test => {
            if (!selectedTests.has(test.id)) {
              testSearchResultsContainer.append(
                `<div class="search-result-item" data-test-id="${test.id}">
                   ${test.name}
                 </div>`
              );
            }
          });
        }
      });
    } else {
      testSearchResultsContainer.empty();
    }
  });

  testSearchResultsContainer.on("click", ".search-result-item", function() {
    const testId = $(this).data("test-id");
    const testName = $(this).text().trim();

    selectedTests.add(parseInt(testId, 10));

    const newItem = `
      <div class="test-item" data-test-id="${testId}">
        <div class="order-number"></div>
        <input type="hidden" name="lesson[test_ids][]" value="${testId}" />
        <input type="text" value="${testName}" class="form-control" disabled />
        <button type="button" class="remove-test-btn">
          <i class="fa fa-trash"></i>
        </button>
      </div>`;

    selectedTestsContainer.append(newItem);
    updateOrder();

    testSearchInput.val("");
    testSearchResultsContainer.empty();
  });

  selectedTestsContainer.on("click", ".remove-test-btn", function() {
    const testItem = $(this).closest(".test-item");
    const testId = testItem.data("test-id");

    selectedTests.delete(parseInt(testId, 10));
    testItem.remove();
    updateOrder();
  });

  $("#add-paragraph-btn").on("click", function() {
    const paragraphCount = selectedParagraphsContainer.children().length;
    const order = paragraphCount + 1;

    const newItem = `
      <div class="paragraph-item">
        <div class="d-flex align-items-center mb-2">
          <div class="order-number me-2">${order}</div>
          <textarea class="form-control" name="lesson[paragraphs][][content]"></textarea>
          <button type="button" class="btn-close ms-2 remove-paragraph-btn" aria-label="Close">
            <i class="fa fa-trash"></i>
          </button>
        </div>
      </div>`;

    selectedParagraphsContainer.append(newItem);
    updateOrder();
  });

  selectedParagraphsContainer.on("click", ".remove-paragraph-btn", function() {
    const paragraphItem = $(this).closest(".paragraph-item");
    paragraphItem.remove();
    updateOrder();
  });

  updateOrder();
});
