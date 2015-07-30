###!
# @author: Fahad Hossain
# @date: July 24, 2015 2:00 AM
# @license: MIT
###

(($, Hh, Px) ->
  # Define the procedures/functions
  # Generate code using Hogan from a given object
  generateCode = (data) ->
    # the mustache template
    template = '''
add_filter("cmb2_meta_boxes", "{{mb_function}}");
function {{mb_function}} (array $meta_boxes) {
  $meta_boxes["{{mb_id}}"] = array(
    "id" => "{{mb_id}}",
    "title" => __("{{mb_title}}", "{{mb_textdomain}}"),
    "object_types" => array({{&mb_scope}}),
    "show_on" => array(
      "key" => "{{mb_so_key}}",
      "value" => "{{mb_so_value}}"
    ),
    "context" => "{{mb_context}}",
    "priority" => "{{mb_priority}}",
    "show_names" => true,
    "fields" => array(
      {{#fields}}
      array(
        "name" => __("{{title}}", "{{textdomain}}"),
        "id" => "{{id}}",
        "type" => "{{type}}",
        "default" => "{{default}}",
        {{#options_cb}}
        "options" => "{{callback}}"
        {{/options_cb}}
        {{^options_cb}}
        "options" => array(
          {{#options}}
          "{{key}}" => __("{{value}}", "{{textdomain}}"),
          {{/options}}
        ),
        {{/options_cb}}
      ),
      {{/fields}}
    )
  );
  return $meta_boxes;
}'''
    # The mustache template compiled using Hogan
    compiled = Hh.compile template
    # Render the template using the provided values
    code = compiled.render data
    # Instert the rendered code into the DOM
    $ '#code'
    .html "<code class=\"language-php\">#{code}</code>"
    # Enable syntax highlighting
    Px.highlightAll()
    $ '#codecontainer'
    .fadeIn()
    return #generateCode
  prepareCode = (object) ->
    object =
      mb_function:
        $ '#mb_function'
        .val()
      mb_id:
        $ '#mb_id'
        .val()
      mb_title:
        $ '#mb_title'
        .val()
      mb_textdomain:
        $ '#mb_textdomain'
        .val()
      mb_scope:
        $ '#mb_scope'
        .val()
        .replace /\b/g, "'"
        .replace /\s/g, ""
      mb_so_key:
        $ '#mb_so_key'
        .val()
      mb_so_value:
        $ '#mb_so_value'
        .val()
      mb_context:
        $ '#mb_context'
        .val()
      mb_priority:
        $ '#mb_priority'
        .val()
      fields: []
    $ '.form-element'
    .each ->
      ljQ = $ @
      field =
        textdomain:
          object.mb_textdomain
        title:
          ljQ
          .find '.mb_field_title'
          .val()
        id:
          ljQ
          .find '.mb_field_id'
          .val()
        type:
          ljQ
          .find '.mb_field_type'
          .val()
        default:
          ljQ
          .find '.mb_field_default'
          .val()
      if ljQ.has('.option-param').length
        options =
          ljQ
          .children '.option-param'
        optionType = options.first().find('.opt-param-type').val()
        if optionType is "callback"
          field.options_cb =
            callback:
              options
              .first()
              .find '.opt-callback'
              .val()
          field.options = false
        else
          field.options_cb = false
          field.options = []
          options.each ->
            tjQ = $ @
            opt =
              key:
                tjQ
                .find '.opt-key'
                .val()
              value:
                tjQ
                .find '.opt-val'
                .val()
              textdomain: object.mb_textdomain
            field.options.push opt
            return #options.each
      object.fields.push field
      return #form-element.each
    #prepareCode
    object #return implicit object
  # End procedures definition section
  dirty = false
  delConf =
    title: "You sure, buddy?",
    text: "Once its gone, it ain't coming back...",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#f44336",
    confirmButtonText: "Yes, delete it!",
    closeOnConfirm: true
  $ document
  .ready ->
    $ '#fields'
    .trigger 'reset'
    .on 'click loadTrig', ->
      if $('.form-element:visible').length is 1
        $ '.form-element:first .remove'
        .prop 'disabled', true
      return
    .trigger 'loadTrig'
    .on 'click', '.add-more', (e) ->
      dirty = true
      e.preventDefault()
      $ @
      .parents '.form-element'
      .find '.remove'
      .prop 'disabled', false
      $ @
      .parents '.form-element'
      .clone()
      .appendTo '#fields'
      .find '.option-param'
      .remove()
      $ @
      .parents '.btn-group-lg'
      .removeClass 'btn-group'
      $ @
      .hide()
      return
    .on 'click', '.remove', (e) ->
      e.preventDefault()
      swal delConf, =>
        $ @
        .parents '.form-element'
        .remove()
        $ '.btn-group-lg'
        .each ->
          $ @
          .addClass 'btn-group'
          return
        $ '#fields'
        .find '.form-element:last'
        .find '.add-more'
        .show()
        $ '.form-element'
        .trigger 'loadTrig'
        return
      return
    .on 'click', '.move-up', (e) ->
      e.preventDefault()
      fe =
        $ @
        .parents '.form-element'
      prevfe =
        $ fe
        .prev '.form-element'
      if prevfe.length > 0
        fe.detach()
        fe.insertBefore prevfe
        fe.find '.add-more'
        .hide()
        $ '#fields'
        .find '.form-element:last'
        .find '.add-more'
        .show()
      return
    .on 'click', '.move-down', (e) ->
      e.preventDefault()
      fe =
        $ @
        .parents '.form-element'
      nextfe =
        $ fe
        .next '.form-element'
      if nextfe.length > 0
        fe.detach()
        fe.insertAfter nextfe
        fe
        .find '.add-more'
        .hide()
        fields = $('#fields')
        fields
        .find '.form-element'
        .find '.add-more'
        .hide()
        fields
        .find '.form-element:last'
        .find '.add-more'
        .show()
      return
    .on 'change', '.mb_field_type', ->
      dropdown = $ @
      selected_option = dropdown.val()
      form_elem = dropdown.parents '.form-element'
      html_element =
        $ '#option-param-elem'
        .children()
      field_types = [
        'multicheck'
        'multicheck_inline'
        'radio'
        'radio_inline'
        'select'
      ]
      position_in_array = $.inArray selected_option, field_types
      has_option_elem =
        form_elem
        .has '.option-param'
        .length
      if position_in_array >= 0 and not has_option_elem
        html_element
        .clone()
        .appendTo form_elem
      else if position_in_array < 0 and has_option_elem
        form_elem
        .find '.option-param'
        .remove()
      return
    .on 'change', '.opt-param-type', ->
      $this = $ @
      form_elem = $this.parents '.form-element'
      form_elem
      .children '.option-param'
      .not ':first'
      .remove()
      form_elem
      .find '[data-opt-type]'
      .addClass 'hidden'
      form_elem
      .find "[data-opt-type=\"#{$this.val()}\"]"
      .removeClass 'hidden'
      return
    .on 'click', '.opt-move-up', (e) ->
      e.preventDefault()
      current = $(@).parents '.option-param'
      prev_elem = current.prev '.option-param'
      if prev_elem.length
        prev_elem.before current
      return
    .on 'click', '.opt-move-down', (e) ->
      e.preventDefault()
      current = $(@).parents '.option-param'
      next_elem = current.next '.option-param'
      if next_elem.length
        next_elem.after current
      return
    .on 'click', '.opt-add', (e) ->
      e.preventDefault()
      $ '.opt-remove'
      .prop 'disabled', false
      $ '#option-param-elem'
      .children()
      .clone()
      .appendTo $(@).parents '.form-element'
      $ @
      .parents '.btn-group-sm'
      .removeClass 'btn-group'
      return
    .on 'click', '.opt-remove', (e) ->
      e.preventDefault()
      swal delConf, =>
        $ @
        .parents '.option-param'
        .remove()
        $ '.btn-group-sm'
        .each ->
          $ @
          .addClass 'btn-group'
          return
        $ '.option-param'
        .trigger 'loadTrig'
        return
      return
    .on 'click loadTrig', ->
      if $('.option-param:visible').length is 1
        $ '.option-param'
        .each ->
          $ @
          .find '.opt-remove'
          .prop 'disabled', true
          return
      return
    .trigger 'loadTrig'
    $ '.code-generator'
    .on 'click', (e) ->
      e.preventDefault()
      elements = prepareCode()
      generateCode elements
      dirty = false
      return #click
    $ window
    .on 'beforeunload', ->
      'You have a work in progress!' if dirty
    return #ready
  return #IIFE
) jQuery, Hogan, Prism
