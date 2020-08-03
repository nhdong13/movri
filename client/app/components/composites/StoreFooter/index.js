import React, { Component } from 'react'
import { onlineStoreActions } from '../../../actions/OnlineStoreActions'
import { connect } from 'react-redux'
import axios from 'axios'
import { randomString, PickColorstyles } from '../../../utils/common'
import { SketchPicker } from 'react-color';
import StoreFooterItem from '../StoreFooterItem'


class StoreFooter extends Component {
  constructor(props) {
    super(props)
    let object =  props.section && props.section.id ? props.section.object : props.object
    this.state = {
      saving: false,
      removing: false,
      sectionRemoving: false,
      textColorEnabled: false,
      bgColorEnabled: false,
      section: props.section,
      object: object
    }

    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleOnSubmit = this.handleOnSubmit.bind(this)
    this.handleTextColorClose = this.handleTextColorClose.bind(this)
    this.handleTextColorToggle = this.handleTextColorToggle.bind(this)
    this.handleBgColorClose = this.handleBgColorClose.bind(this)
    this.handleBgColorToggle = this.handleBgColorToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleUpdateChildItem = this.handleUpdateChildItem.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)
    this.handleUpdateNewItem = this.handleUpdateNewItem.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)
    this.handleRemoveSection = this.handleRemoveSection.bind(this)

  }

  handleOnChange(e) {
    let { value } = e.target
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    this.setState({
      object: {
        ...this.state.object,
        [e.target.name]: value
      }
    })
  }

  handleOnSubmit(e) {
    e.preventDefault()
    const { object } = this.state
    const axiosOptions = {
      url: object.id ? `/admin/store_footers/${object.id}` : `/admin/store_footers`,
      method: object.id ? 'put' : 'post',
      data: {
        authenticity_token: this.props.onlineStore.authenticityToken,
        store_footer: object
      }
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      if (res.data.success) {
        const { section } = res.data
        this.setState({
          saving: false,
          section: section,
          object: section.object
        })
        this.handleUpdateChildItem(section)
        $("#homepage-preview-iframe").attr("src", function(index, attr){ 
          return attr;
        });
      }
    })
  }

  handleTextColorClose() {
    this.setState({
      textColorEnabled: false
    })
  }

  handleBgColorClose() {
    this.setState({
      bgColorEnabled: false
    })
  }

  handleTextColorToggle() {
    this.setState({
      textColorEnabled: !this.state.textColorEnabled
    })
  }

  handleBgColorToggle() {
    this.setState({
      bgColorEnabled: !this.state.bgColorEnabled
    })
  }

  handleTextColorChangeComplete(target, color){
    this.setState({
      object: {
        ...this.state.object,
        [target]: color.hex
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

  handleAddItem() {
    const newItem = {
      store_footer_id: this.state.object.id,
      heading: '',
      sub_heading: '',
      text: '',
      link: ''
    }
    this.setState({
      object: {
        ...this.state.object,
        items: [...this.state.object.items, newItem]
      }
    })
  }

  handleUpdateNewItem(oldId, item){
    let items = this.state.object.items
  
    let oldItemIndex = items.findIndex(it => it.id === oldId)
    oldItemIndex > -1 ? items.splice(oldItemIndex, 1, item) : items.push(item)
    this.setState({
      object: {
        ...this.state.object,
        items: items
      }
    })
  }

  handleRemoveItem(item) {
    // TODO
    this.setState({ removing: true })
    
    axios.delete(`/admin/store_footers/${item.store_footer_id}/store_footer_items/${item.id}`, {data: {authenticity_token: this.props.onlineStore.authenticityToken}}).then(res => {
      this.setState({removing: false})
      let items = this.state.object.items.filter(it => it.id != item.id)
      this.setState({
        object: {
          ...this.state.object,
          items: items
        }
      })

      this.setState({ removing: false })

      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleRemoveSection() {
    if (this.state.object.id) {
      const params = {
        authenticity_token: this.props.onlineStore.authenticityToken
      }
      this.setState({ sectionRemoving: true })
      axios.delete(`/admin/store_footers/${this.state.object.id}`, {data:  params}).then(res => {
        if (res.data.success) {
          this.setState({sectionRemoving: false})
          this.props.removeSectionItem(this.state.section.id)
          this.props.callback(undefined)
        } else {
          console.log(res.data.messages)
        }
      })
    } else {
      this.props.callback(undefined)
    }
  }

  render() {
    let { object } = this.state
    return (
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.callback(undefined)}>
          <i className="icon-chevron-left"></i>
          <span>{object.name || 'Footer'}</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleOnSubmit}>
            <div className='form-control'>
              <label>Footer name(Contact us...)</label>
              <input name='name' value={object.name} type='text' onChange={this.handleOnChange}/>
            </div>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='enabled' 
                type='checkbox'
                checked={object.enabled || false}
                onChange={this.handleOnChange}
                id='enabled' />
              <label htmlFor='enabled' className='checkbox-label'>{`Enable ${object.name}`}</label>
            </div>
            <div className='form-control'>
              <button
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: object.text_color}} 
                  onClick={this.handleTextColorToggle}>
              </button>
              <label>Text color</label>
              {this.state.textColorEnabled && 
                <div>
                  <div style={ PickColorstyles.cover } onClick={ this.handleTextColorClose }/>
                  <SketchPicker
                    color={ object.text_color }
                    onChangeComplete={(e) => this.handleTextColorChangeComplete('text_color', e) }
                  />
                </div>
              }
            </div>
            <div className='form-control'>
              <button
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: object.background_color}} 
                  onClick={this.handleBgColorToggle}>
              </button>
              <label>Background color</label>
              {this.state.bgColorEnabled && 
                <div>
                  <div style={ PickColorstyles.cover } onClick={ this.handleBgColorClose }/>
                  <SketchPicker
                    color={ object.background_color }
                    onChangeComplete={(e) => this.handleTextColorChangeComplete('background_color', e) }
                  />
                </div>
              }
            </div>
            <button className='btn' type='submit'>{this.state.saving ? 'Saving...' : 'Save'}</button>
          </form>
          <hr></hr>
          <h1>Content</h1>
          <ul className='slide-list'>
            {
              object.items.map(item => {
                return <li key={item.id || randomString()}>
                  <StoreFooterItem 
                  key={item.id || randomString()}
                  item={item}
                  removing={this.state.removing}
                  handleUpdateNewItem={this.handleUpdateNewItem}
                  handleRemoveItem={this.handleRemoveItem} />
                </li>
              })
            }
            <div className='row'>
              <div className='col-6'>
                <button className='btn' type='button' onClick={this.handleRemoveSection}>{ this.state.sectionRemoving ? 'Removing...' : 'Remove section'}</button>
              </div>
              <div className='add-more-slide col-6'>
                <button className='btn' type='button' onClick={this.handleAddItem}>Add blocks</button>
              </div>
            </div>
            
          </ul>
        </div>
      </div>
    )
  }
}

StoreFooter.defaultProps = {
  object: {
    name: '',
    items: []
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

export default connect(mapStateToProps, mapDispatchToProps)(StoreFooter)