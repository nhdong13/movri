import React, { Component } from 'react'
import { editorCustomConfig, randomString } from '../../../utils/common'

class SimpleCkeditor extends Component {
  constructor(props) {
    super(props)
    this.editor = null
    this.onChange = this.onChange.bind(this)
    this.editorID = randomString()
  }

  componentDidMount() {
    this.editor = CKEDITOR.replace(`editor-${this.editorID}`, editorCustomConfig)
    this.editor.on('change', (evt) => {
      this.props.handleOnChange({target: {name: 'text', value: evt.editor.getData()}})
    })
  }

  onChange(e) {
    console.log(e.value)
  }

  render() {
    return (
      <textarea name={this.props.name} value={this.props.value} id={`editor-${this.editorID}`} onChange={this.onChange}></textarea>
    )
  }
}

export default SimpleCkeditor