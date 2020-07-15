import React, { Component } from 'react'
// import { EditorState, convertToRaw, ContentState } from 'draft-js'
// import draftToHtml from 'draftjs-to-html'
// import htmlToDraft from 'html-to-draftjs'

// import { Editor } from 'react-draft-wysiwyg';

// let Editor = null

class ContactInformation extends Component {
  constructor(props) {
    super(props)
    this.state = {
      ready: false,
      item: props.item,
    }
    // this.onEditorStateChange = this.onEditorStateChange.bind(this)

    // const html = props.item.text ? props.item.text : ''
    // const contentBlock = htmlToDraft(html)
    // if (contentBlock) {
    //   const contentState = ContentState.createFromBlockArray(contentBlock.contentBlocks);
    //   const editorState = EditorState.createWithContent(contentState);
    //   this.state = {
    //     ready: false,
    //     item: props.item, 
    //     editorState,
    //   }
    // } else {
    //   this.state = {
    //     ready: false,
    //     item: props.item, 
    //     editorState: EditorState.createEmpty()
    //   };
    // }
  }

  onEditorStateChange(editorState) {
    const textHTML = draftToHtml(convertToRaw(editorState.getCurrentContent()))
    this.setState({
      editorState,
      item: {
        ...this.state.item,
        text: textHTML
      }
    })
    this.props.handleOnChange({target: {name: 'text', value: textHTML}})
  };

  render() {
    const { item } = this.props
    return(
      <div>
        <div className='form-control'>
          <label>Heading</label>
          <input name='heading' value={item.heading} type='text' onChange={this.props.handleOnChange}/>
        </div>
        <div className='form-control'>
          <label>Text</label>
          <textarea name='text' onChange={this.props.handleOnChange}></textarea>
          {/* <Editor
            editorState={this.state.editorState}
            toolbarClassName="toolbarClassName"
            wrapperClassName="wrapperClassName"
            editorClassName="editorClassName"
            onEditorStateChange={this.onEditorStateChange}
          /> */}
        </div>
      </div>
    )
  }
}

ContactInformation.defaultProps = {
  item: {}
}

export default ContactInformation