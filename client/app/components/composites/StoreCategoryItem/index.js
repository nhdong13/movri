import React, { Component } from  'react'
import ImageUploader from 'react-images-upload';
import axios from 'axios'
import { previewUploadImageSrc } from '../../../utils/common'


class StoreCategoryItem extends Component {
  constructor(props) {
    super(props)
    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      item: props.item,
      categories: [],
      categorySelecting: false
    }

    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.onDrop = this.onDrop.bind(this)
    this.fectchingCategories = this.fectchingCategories.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }
  }

  componentDidMount() {
    this.fectchingCategories()
  }

  componentWillReceiveProps(nextProps ) {
    if (nextProps.item !== this.state.item) {
      this.setState({
        item: nextProps.item
      })
    }
  }

  handleToggleItem() {
    this.setState({
      collapsed: !this.state.collapsed
    })
  }

  handleOnChange(e) {
    this.setState({
      item: {
        ...this.state.item,
        [e.target.name]: e.target.value
      }
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const {item} = this.state
    const formData = new FormData();
    const store_category_item = {
      category_id: item.category_id,
    }

    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())

    for (let key in store_category_item) {
      formData.append(`store_category_item[${key}]`, store_category_item[key])
    }

    if (item.image) {
      formData.append('store_category_item[image]', item.image[0])
    }

    const axiosOptions = {
      url: item.id ? `/admin/store_categories/${item.store_category_id}/store_category_items/${item.id}` :  `/admin/store_categories/${item.store_category_id}/store_category_items`,
      method: item.id ? 'put' : 'post',
      data: formData 
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.setState({
        saving: false,
        collapsed: false,
      })
      this.props.handleUpdateNewItem(item.id, res.data.store_category_item)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  onloadCallback(src){
    this.setState({
      item: {
        ...this.state.item,
        image_url: src
      }
    })
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    this.setState({
      item: {
        ...this.state.item,
        image: image
      }
    })
   
  }

  fectchingCategories() {
    if (!this.state.categories.length) {
      axios.get(`/admin/categories.json`, this.axiosDefaultParams, { headers: {'Content-Type': 'application/json'} }).then(res => {
        this.setState({
          categories: res.data.categories,
          categorySelecting: true
        })
      })
    } else {
      this.setState({ categorySelecting: true })
    }
    
  }

  render() {
    return (
      <div className='collapsible store-category-item slideshow-item'>
        <div className='row section-column-header-toggle' onClick={this.handleToggleItem}>
          <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
          <div className='heading-title'>{this.state.item.title || 'Category'}</div>
        </div>
        {
          this.state.collapsed && <div className='collapse-item'>
            <form onSubmit={this.handleSubmitForm}>
              <div className='form-control'>
                <label>Category: </label>
                <div className='select-collection'>
                  <select name='category_id' onChange={this.handleOnChange} value={this.state.item.category_id}>
                    <option>Select collection</option>
                    { 
                      this.state.categories.map(opt => {
                        return (<option value={opt.id} key={opt.id}>{opt.translations[0].name}</option>)
                      }) 
                    }
                  </select>
                </div>
              </div>
              <div className='background-image'>
                <label>Image</label>
                { this.state.item.image_url && <img src={this.state.item.image_url} alt='item-image'/>}
                <ImageUploader
                  className='logo-uploader'
                  withLabel={false}
                  withIcon={false}
                  buttonText='Choose images'
                  onChange={this.onDrop}
                  imgExtension={['.jpg', '.gif', '.png', '.gif']}
                  maxFileSize={5242880}
                  name='image'
                  singleImage={true}
                />
              </div>
              <div className='row'>
                <div className='col-8'>
                  <button className='p-2 btn' type='button' onClick={() => this.props.handleRemoveItem(this.state.item)}>{ this.props.removing ? 'Removing...' : 'Remove content'}</button>
                </div>
                <div className='col-4'>
                  <button className='p-2 btn' type='submit'>{ this.state.saving ? 'Saving' : 'Save' }</button>
                </div>
              </div>
            </form>
          </div>
        }
      </div>
    )
  }
}

StoreCategoryItem.defaultProps = {
  item: {title: 'Category'},
  categories: []
}

export default StoreCategoryItem
