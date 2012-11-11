removeSelector = (e) =>
  e.preventDefault()
  $(e.currentTarget).parent().remove()

addSelector = (e) =>
  e.preventDefault()
  $("<li><input type='text' name='selectors[]' placeholder='Enter a CSS selector'><input class='lightblue preview-selector' type='button' value='Preview'><a href='#' class='remove-selector'>Remove</a></li>").appendTo('.additional-selectors').children('.remove-selector').click(removeSelector)

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
  else
    $('.preview').css('word-wrap', 'normal')

$ =>
  $('.add-selector').click(addSelector)
  $('.preview-wrap-text input').change(togglePreviewWrapText)
