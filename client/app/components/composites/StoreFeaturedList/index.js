import React, { Component } from 'react'
import MultiSelect from "react-multi-select-component";
import { SketchPicker } from 'react-color';
import axios from 'axios'
import { onlineStoreActions } from '../../../actions/OnlineStoreActions'
import { connect } from 'react-redux'

const renameKeys = (arr) => {
  const newArray = arr.map(elm => {
    return {value: elm.id, label: elm.title}
  })

  return newArray
}

class StoreFeaturedList extends Component {
  constructor(props) {
    super(props)
    const section = props.section
    let object = section && section.id ? section.object : props.object
    this.state = {
      saving: false,
      removing: false,
      section: props.section,
      object: object,
      textColorEnabled: false,
      featuredProducts: [],
      productSelected: object.selected_products
    }

    this.fectchingFeaturedProducts  = this.fectchingFeaturedProducts.bind(this)
    this.setSelected = this.setSelected.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleOnSubmit = this.handleOnSubmit.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.colorPickToggle = this.colorPickToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleRemoveSection = this.handleRemoveSection.bind(this)
    this.handleUpdateChildItem = this.handleUpdateChildItem.bind(this)

    axios.defaults.params = {
      authenticity_token: props.onlineStore.authenticityToken
    }
  }

  componentDidMount() {
    this.fectchingFeaturedProducts()
  }

  fectchingFeaturedProducts() {
    axios.get(`/admin/communities/${this.props.onlineStore.community_id}/listings.json`).then(res => {
      if (res.status === 200) {
        const productOptions = renameKeys(res.data)
        this.setState({
          featuredProducts: productOptions
        })
      }
    })
  }

  setSelected(items) {
    const productIds = items.map(i => { return i.value })
    this.setState({
      productSelected: items,
      object: {
        ...this.state.object,
        product_ids: productIds
      }
    })
  }

  handleOnChange(e) {
    this.setState({
      object: {
        ...this.state.object,
        [e.target.name]: e.target.value
      }
    })
  }

  handleUpdateChildItem(section) {
    let ssection = this.props.sections.find(i => i.id === section.id)

    if (ssection) {
      this.props.updateSectionItem(section)
    } else {
      this.props.addSectionItem(section)
    } 
  }

  handleOnSubmit (e) {
    e.preventDefault()
    const { object } = this.state
    const axiosOptions = {
      url: object.id ? `/admin/store_featured_products/${object.id}` : `/admin/store_featured_products`,
      method: object.id ? 'put' : 'post',
      data: { 
        authenticity_token: this.props.onlineStore.authenticityToken,
        store_featured_product: object
       }
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      const { section } = res.data
      this.setState({
        saving: false,
        section: section,
        object: section.object
      })
      this.handleUpdateChildItem(section)
    })
  }

  handleColorClose() {
    this.setState({ textColorEnabled: false })
  }

  colorPickToggle() {
    this.setState({ textColorEnabled: !this.state.textColorEnabled })
  }

  handleTextColorChangeComplete(color) {
    this.setState({
      object: {
        ...this.state.object,
        button_text_color: color.hex
      }
    })
  }

  handleRemoveSection(item) {
    if (item.id) {
      const params = {
        authenticity_token: this.props.onlineStore.authenticityToken
      }
      this.setState({ removing: true })
      axios.delete(`/admin/store_featured_products/${item .id}`, {data:  params}).then(res => {
        this.setState({removing: false})
        this.props.removeSectionItem(this.state.section.id)
        this.props.callback(undefined)
      })
    } else {
      this.props.callback(undefined)
    }
    
  }

  render() {
    const styles = {
      cover: {
        position: 'fixed',
        top: '0px',
        right: '0px',
        bottom: '0px',
        left: '0px',
      }
    }

    return (
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.callback(undefined)}>
          <i className="icon-chevron-left"></i>
          <span>{this.state.object.heading || 'Featured List'}</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleOnSubmit}>
            <div className='form-control'>
              <label>Heading</label>
              <input name='heading' value={this.state.object.heading || ''} type='text' onChange={this.handleOnChange}/>
            </div>
            <div className='form-control'>
              <MultiSelect
                options={this.state.featuredProducts}
                value={this.state.productSelected}
                onChange={this.setSelected}
                className='featured-list'
                labelledBy={"Select products"}
              />
            </div>
            <div>
              <ul>
                {
                  this.state.productSelected.map(p => {
                    return <li key={p.value}>{p.label}</li>
                  })
                }
              </ul>
            </div>
            <hr></hr>
            <label>CALL TO ACTION</label>
            <div className='form-control'>
              <button
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: this.state.object.button_text_color}} 
                  onClick={this.colorPickToggle}>
              </button>
              <label>Text color</label>
              {this.state.textColorEnabled && 
                <div>
                  <div style={ styles.cover } onClick={ this.handleColorClose }/>
                  <SketchPicker
                    color={ this.state.object.button_text_color }
                    onChangeComplete={ this.handleTextColorChangeComplete }
                  />
                </div>
              }
            </div>
            <hr></hr>
            <div className='row'>
              <div className='col-6'>
                <button className='btn' type='button' onClick={() => this.handleRemoveSection(this.state.object)}>{ this.state.removing ? 'Removing...' : 'Remove section'} </button>
              </div>
              <div className='col-6'>
                <button className='btn' type='submit'>{ this.state.saving ? 'Saving...' : 'Save'} </button> 
              </div>
            </div>
          </form>
        </div>
      </div>
    )
  }
}

StoreFeaturedList.defaultProps = {
  object: {
    heading: 'Featured List',
    product_ids: [],
    selected_products: []
  }
}

const mapStateToProps = (state) => {
  return {
    onlineStore: state.onlineStore,
    sections: state.onlineStore.sections
  }
}

const mapDispatchToProps = {
  addSectionItem: onlineStoreActions.addSectionItem,
  updateSectionItem: onlineStoreActions.updateSectionItem,
  removeSectionItem: onlineStoreActions.removeSectionItem
}

export default connect(mapStateToProps, mapDispatchToProps)(StoreFeaturedList)