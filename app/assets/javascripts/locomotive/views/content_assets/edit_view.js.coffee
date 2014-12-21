Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.EditView extends Backbone.View

  events:
    'click .apply-btn':     'apply'
    'click .resize-btn':    'toggle_resize_modal'
    'click .crop-btn':      'enable_crop'

  initialize: ->
    _.bindAll(@, 'change_size', 'apply_resizing', 'update_cropper_label')
    super

  render: ->
    @filename   = @$('.image-container').data('filename')
    @width      = parseInt(@$('.image-container').data('width'))
    @height     = parseInt(@$('.image-container').data('height'))
    @ratio      = @width / @height

    @create_cropper()
    @create_resize_popover()

  create_cropper: ->
    @$cropper = @$(".image-container > img")

    @set_cropper_height()
    @$cropper.cropper
      autoCrop: false
      done: @update_cropper_label

  create_resize_popover: ->
    @$link    = @$('.resize-btn')
    @$content = @$('.resize-form').show()

    @$content.find('input').on 'keyup', @change_size
    @$content.find('.apply-resizing-btn').on 'click', @apply_resizing

    @$link.popover
      container:  '.main'
      placement:  'left'
      content:    @$content
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

  enable_crop: (event) ->
    @cropper_enabled = true
    @$cropper.cropper('clear')
    @$cropper.cropper('setDragMode', 'crop')

  toggle_resize_modal: (event) ->
    state = if @resize_modal_opened then 'hide' else 'show'
    @$link.popover(state)
    @resize_modal_opened = !@resize_modal_opened

  change_size: (event) ->
    $input  = $(event.target)
    value   = parseInt($input.val().replace(/\D+/, ''))

    return if _.isNaN(value)

    # make sure the value is an integer
    $input.val(value)

    if $input.attr('name') == 'width'
      _value = Math.round(value / @ratio)
      @$content.find('input[name=height]').val(_value)
    else
      _value = Math.round(value * @ratio)
      @$content.find('input[name=width]').val(_value)

  apply_resizing: (event) ->
    event.stopPropagation() & event.preventDefault()
    $btn = $(event.target).button('loading')

    width   = parseInt(@$content.find('input[name=width]').val())
    height  = parseInt(@$content.find('input[name=height]').val())

    window.resizeImageStep @$cropper[0], width, height
      .then (image) =>
        @width  = width
        @height = height
        @$cropper.cropper('replace', image.src)
        @set_cropper_height()
        $btn.button('reset')
        @toggle_resize_modal()

  apply: (event) ->
    event.stopPropagation() & event.preventDefault()

    return unless @cropper_enabled

    $link     = $(event.target).closest('.apply-btn')
    image_url = @$cropper.cropper('getDataURL')
    blob      = window.dataURLtoBlob(image_url)

    form_data = new FormData()
    form_data.append('xhr', true)
    form_data.append('content_asset[source]', blob, @filename)

    $.ajax
      url:          $link.data('url')
      type:         'POST'
      data:         form_data
      processData:  false
      contentType:  false
      success: (data) => @options.drawer.close()

  set_cropper_height: ->
    container_height = @$('.edit-assets-container').height()

    if @height < container_height
      @$('.image-container').css('max-height', @height)
    else
      @$('.image-container').css('max-height', 'inherit')

  update_cropper_label: (data) ->
    $dragger  = @$('.cropper-dragger')
    width     = Math.round(data.width)
    height    = Math.round(data.height)

    $label = $dragger.find('> .cropper-label')

    if $label.size() == 0
      $label = $dragger.append('<span class="cropper-label"><span>').find('> .cropper-label')

    $label.html("#{width} x #{height}")

  remove: ->
    console.log '[EditView] remove'
    @$cropper.cropper('destroy')
    @$link.popover('destroy')
    super
