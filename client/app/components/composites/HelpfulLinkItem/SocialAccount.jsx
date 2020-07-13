import React, { Component } from 'react'
import { randomString, previewUploadImageSrc } from '../../../utils/common'
import ImageUploader from 'react-images-upload'

class SocialAccount extends Component {
  constructor(props) {
    super(props)
    this.state = {
      item: props.item,
      sub_items: props.item.sub_items
    }

    this.handleAddNewSubItem = this.handleAddNewSubItem.bind(this)
    this.handleItemOnChange = this.handleItemOnChange.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.onDrop = this.onDrop.bind(this)
  }

  handleAddNewSubItem() {
    const subItem = {
      alt_text: '',
      link: '',
      id: randomString()
    }

    const subItems =  [...this.props.item.sub_items, subItem]

    this.props.handleOnChange({target: {name: 'sub_items', value: subItems}})
  }

  handleItemOnChange(id, e) {
    let subItems = this.props.item.sub_items
    let subItem = subItems.find(i => i.id === id)
    let oldItemIndex = subItems.findIndex(it => it.id === id)
    subItem = {
      ...subItem,
      [e.target.name]: e.target.value
    }

    oldItemIndex > -1 ? subItems.splice(oldItemIndex, 1 , subItem) : subItems.push(subItem)

    this.props.handleOnChange({target: {name: 'sub_items', value: subItems}})
  }

  onloadCallback(id, src){
    const e = {
      target: { name: 'image_url', value: src}
    }

    this.handleItemOnChange(id, e)
    // let subItems = this.props.item.sub_items
    // let subItem = subItems.find(i => i.id === id)
    // let oldItemIndex = subItems.findIndex(it => it.id === id)
    // subItem = {
    //   ...subItem,
    //   [e.target.name]: e.target.value
    // }
    // this.setState({
    //   item: {
    //     ...this.state.item,
    //     image_url: src
    //   }
    // })
  }

  onDrop(id, image) {
    previewUploadImageSrc(image, this.onloadCallback, id)
    const e = {
      target: {name: 'image', value: image}
    }
    this.handleItemOnChange(id, e)
    // this.setState({
    //   item: {
    //     ...this.state.item,
    //     image: image
    //   }
    // })
  }

  render() {
    const { item } = this.props
    return(
      <div>
        <div className='form-control'>
          <label>Heading</label>
          <input name='heading' value={item.heading} type='text' onChange={this.props.handleOnChange}/>
        </div>
        <label>Social Account</label>
        {
          item.sub_items.map(sub => {
            return(
              <div key={sub.id || randomString()}>
                <hr></hr>
                <div>
                  <div className='form-control'>
                    <label>Alt Text</label>
                    <input name='alt_text' value={sub.alt_text} type='text' onChange={(e) => this.handleItemOnChange(sub.id, e)}/>
                  </div>
                  <div className=''>
                    <img src={sub.image_url} alt='logo-image' />
                    <ImageUploader
                      className='logo-uploader'
                      withLabel={false}
                      withIcon={false}
                      buttonText='Choose images'
                      onChange={(image) => this.onDrop(sub.id, image)}
                      imgExtension={['.jpg', '.gif', '.png', '.gif']}
                      maxFileSize={5242880}
                      singleImage={true}
                    />
                  </div>
                  <div className='form-control'>
                    <label>Link</label>
                    <input name='link' value={sub.link} type='text' onChange={(e) => this.handleItemOnChange(sub.id, e)}/>
                  </div>
                </div>
              </div>
            )
          })
        }
        <button className='p-2 btn' type='button' onClick={this.handleAddNewSubItem}>Add Sub heading</button>
      </div>
    )
  }
}

SocialAccount.defaultProps = {
  item: {
    sub_items: []
  }
}

export default SocialAccount

