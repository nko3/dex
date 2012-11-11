tagsInputOptions =
  defaultText: 'add attributes'
  height: '45px'
  width: '320px'

scrapePath = =>
  params =
    url: urlValue()
    s: selectors()

  "/api.json?#{decodeURIComponent($.param(params)).replace(/#/g, '%23')}"

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

    custom_key = $.trim($input.siblings().find("input[name='custom-key']").val())
    console.log "CUSTOM",$.trim($input.siblings().find("input[name='custom-key']").val())
    if custom_key != ""
      value['c'] = custom_key

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
  $html = $("<li class='selector'><input type='text' name='selectors[]' placeholder='Enter a CSS selector'><a href='#' class='remove-selector'>Remove</a><p><input name='innerText' type='checkbox' checked='checked'> Extract innerText<p><label>List of element attributes to extract (optional)</label><input name='attributes'><p><label>Customize the hash key for the JSON output (optional)</label><input name='custom-key' type='text' placeholder='Custom JSON key'></li>")
  $html.appendTo('.additional-selectors')
  $html.find('.remove-selector').click(removeSelector)
  $html.find("input[name='attributes']").tagsInput(tagsInputOptions)

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
    $('.preview pre').css('white-space', 'pre-wrap')
  else
    $('.preview').css('word-wrap', 'normal')
    $('.preview pre').css('white-space', 'pre')

updatePreview = (error, data) =>
  if error
    json = data[0].responseText
  else
    json = JSON.stringify(data, null, '  ')
  $('.preview pre').text(json)
  hljs.highlightBlock($(".preview pre")[0])

prefill = =>
  $("input[name='url']").val("http://www.google.com/")
  $("input[name='selectors[]']:first").val("meta")
  $("input[name='innerText']:first").prop("checked", "")
  $("input[name='attributes']:first").importTags('name,content')
  $("input[name='custom-key']:first").val("google_meta_tags")
  $(".add-selector").trigger('click')
  $("input[name='selectors[]']:last").val("#gb a")
  $("input[name='attributes']:last").importTags('href')
  $("input[name='custom-key']:last").val("google_nav_links")
  $(".preview-all").trigger("click")

$ =>
  $('.add-selector').click(addSelector)
  $('.preview-all').click(previewAll)
  $('.preview-wrap-text input').change(togglePreviewWrapText)
  $("input[name='attributes']").tagsInput(tagsInputOptions)
  $('.done').click(done)
  if window.location.hash == "#example"
    prefill()

