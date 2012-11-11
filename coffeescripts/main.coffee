urlValue = =>
  value = $.trim($("input[name='url_example']").val())
  if value == "" then null else value

selectorValue = ($input) =>
  value = $.trim($input.val())
  if value == "" then null else value

selectors = =>
  allSelectors = _.map $("input[name='selectors[]']"), (input) =>
    selectorValue($(input))
  notNilSelectors = _.filter allSelectors, (selectorValue) =>
    selectorValue?
  notNilSelectors

previewSelector = (e) =>
  e.preventDefault()
  selector = selectorValue($(e.currentTarget).parent().find("input[name='selectors[]']"))

  return alert("Please enter a CSS selector")  unless selector?
  makePreviewPost([selector])

previewAll = (e) =>
  e.preventDefault()
  return alert("Please enter at least one CSS selector.")  unless selectors().length > 0
  makePreviewPost(selectors())

makePreviewPost = (allSelectors) =>
  return alert("Please enter an example URL to test the selectors on.")  unless urlValue()?

  $.ajax
    type: 'POST'
    url: '/preview'
    dataType: 'json'
    data:
      url: urlValue()
      selectors: allSelectors
    success: (data) =>
      updatePreview(false, data)
    error: (jqXHR, textStatus, error) =>
      updatePreview(true, [jqXHR, textStatus, error])

removeSelector = (e) =>
  e.preventDefault()
  $(e.currentTarget).parent().remove()

addSelector = (e) =>
  e.preventDefault()
  $html = $("<li><input type='text' name='selectors[]' placeholder='Enter a CSS selector'><input class='lightblue preview-selector' type='button' value='Preview'><a href='#' class='remove-selector'>Remove</a></li>")
  $html.appendTo('.additional-selectors')
  $html.children('.remove-selector').click(removeSelector)
  $html.children('.preview-selector').click(previewSelector)

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
  else
    $('.preview').css('word-wrap', 'normal')

updatePreview = (error, data) =>
  if error
    json = data[0].responseText
  else
    json = JSON.stringify(data, null, '  ')
  $('.preview pre').text(json)
  hljs.highlightBlock($(".preview pre")[0])

saveScraper = (e) =>
  e.preventDefault()

  return alert("Please enter an example URL to test the selectors on.")  unless urlValue()?
  return alert("Please enter at least one CSS selector.")  unless selectors().length > 0

  $.ajax
    type: 'POST'
    url: '/create'
    data:
      title: $("input[name='title']").val()
      url_example: urlValue()
      selectors: selectors()
    dataType: 'json'
    success: (json) =>
      window.location.href = json['path']
    error: (jqXHR, textStatus, error) =>
      alert("Error: #{JSON.parse(jqXHR.responseText)['message']}")

$ =>
  $('.add-selector').click(addSelector)
  $('.preview-selector').click(previewSelector)
  $('.preview-all').click(previewAll)
  $('.preview-wrap-text input').change(togglePreviewWrapText)
  $('.save-scraper').click(saveScraper)

