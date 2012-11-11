tagsInputOptions =
  defaultText: 'add attributes'
  height: '45px'
  width: '320px'

scrapePath = =>
  params =
    url: urlValue()
    s: selectors()

  "/scrape?#{decodeURIComponent($.param(params))}"

urlValue = =>
  value = $.trim($("input[name='url']").val())
  if value == "" then null else value

selectorValue = ($input) =>
  value = $.trim($input.val())
  if value == "" then null else value

selectors = =>
  allSelectors = []
  $("input[name='selectors[]']").each ->
    $input = $(@)
    value = {v: selectorValue($input)}
    unless $input.siblings().find("input[name='innerText']").is(':checked')
      value['t'] = 'f'

    $input.siblings().find("input[name='attributes']").siblings().find(".tag span").each ->
      value['a'] ?= []
      value['a'].push($.trim($(@).text()))
    allSelectors.push(value)

  notNilSelectors = _.filter allSelectors, (selectorValue) =>
    selectorValue['v']?
  notNilSelectors

previewAll = (e) =>
  e.preventDefault()

  return alert("Please enter at least one CSS selector.")  unless selectors().length > 0
  return alert("Please enter an example URL to test the selectors on.")  unless urlValue()?

  $.ajax
    type: 'GET'
    url: scrapePath()
    dataType: 'json'
    success: (data) =>
      updatePreview(false, data)
    error: (jqXHR, textStatus, error) =>
      updatePreview(true, [jqXHR, textStatus, error])

done = (e) =>
  e.preventDefault()

  return alert("Please enter at least one CSS selector.")  unless selectors().length > 0
  return alert("Please enter an example URL to test the selectors on.")  unless urlValue()?

  window.location.href = scrapePath()

removeSelector = (e) =>
  e.preventDefault()
  $(e.currentTarget).parent().remove()

addSelector = (e) =>
  e.preventDefault()
  $html = $("<li class='selector'><input type='text' name='selectors[]' placeholder='Enter a CSS selector'><a href='#' class='remove-selector'>Remove</a><p><input name='innerText' type='checkbox' checked='checked'> Extract innerText<p><input name='attributes'></li>")
  $html.appendTo('.additional-selectors')
  $html.find('.remove-selector').click(removeSelector)
  $html.find("input[name='attributes']").tagsInput(tagsInputOptions)

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
    $('.preview pre').css('white-space', 'pre-wrap')
  else
    $('.preview').css('word-wrap', 'normal')
    $('.preview pre').css('white-space', 'nowrap')

updatePreview = (error, data) =>
  if error
    json = data[0].responseText
  else
    json = JSON.stringify(data, null, '  ')
  $('.preview pre').text(json)
  hljs.highlightBlock($(".preview pre")[0])

$ =>
  $('.add-selector').click(addSelector)
  $('.preview-all').click(previewAll)
  $('.preview-wrap-text input').change(togglePreviewWrapText)
  $("input[name='attributes']").tagsInput(tagsInputOptions)
  $('.done').click(done)

