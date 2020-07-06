import React, { Component } from 'react'
import { onlineStoreActions } from '../../../actions/OnlineStoreActions'
import { connect } from 'react-redux'
import axios from 'axios'
import StoreGridItem from '../StoreGridItem'
import { randomString } from '../../../utils/common'


class StoreGrid extends Component {
  constructor(props) {
    super(props)
    this.handleOnSubmit = this.handleOnSubmit.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleUpdateChildItem = this.handleUpdateChildItem.bind(this)
    this.handleRemoveSection = this.handleRemoveSection.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)
    this.handleUpdateNewItem = this.handleUpdateNewItem.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)


    let object = props.section && props.section.id ? props.section.object : props.object
    this.state = {
      saving: false,
      removing: false,
      sectionRemoving: false,
      section: props.section,
      object: object
    }
  }

  handleOnSubmit(e) {
    e.preventDefault()
    const { object } = this.state
    const axiosOptions = {
      url: object.id ? `/admin/store_grids/${object.id}` : `/admin/store_grids`,
      method: object.id ? 'put' : 'post',
      data: {
        authenticity_token: this.props.onlineStore.authenticityToken,
        store_grid: object
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
      }
    })
  }

  handleOnChange(e) {
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    this.setState({
      object: { ...this.state.object, [e.target.name]: value }
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


  handleRemoveSection() {
    if (this.state.object.id) {
      const params = {
        authenticity_token: this.props.onlineStore.authenticityToken
      }
      this.setState({ sectionRemoving: true })
      axios.delete(`/admin/store_grids/${this.state.object.id}`, {data:  params}).then(res => {
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

  handleAddItem() {
    const newItem = {
      store_grid_id: this.state.object.id
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
    
    axios.delete(`/admin/store_grids/${item.store_grid_id}/store_grid_items/${item.id}`, {data: {authenticity_token: this.props.onlineStore.authenticityToken}}).then(res => {
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

  render() {
    return (
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.callback(undefined)}>
          <i className="icon-chevron-left"></i>
          <span>{this.state.object.heading || 'Grid'}</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleOnSubmit}>
            <div className='form-control'>
              <label>Heading</label>
              <input name='heading' value={this.state.object.heading} type='text' onChange={this.handleOnChange}/>
            </div>
            <div className='form-control'>
              <label>Section height</label>
              <select name='height' value={this.state.object.height} onChange={this.handleOnChange}>
                <option value='small'>Small</option>
              </select>
            </div>
            <div className='form-control'>
              <label>Text alignment</label>
              <select name='text_alignment' value={this.state.object.text_alignment} onChange={this.handleOnChange}>
                <option value='bottom_center'>Bottom Center</option>
              </select>
            </div>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='maintain_aspect_ratio' 
                type='checkbox'
                checked={this.state.object.maintain_aspect_ratio || false}
                onChange={this.handleOnChange}
                id='maintain_aspect_ratio' />
              <label htmlFor='maintain_aspect_ratio' className='checkbox-label'>Maintain aspect ratio</label>
            </div>
            <hr></hr>
            <div className='form-control'>
              <label>MOBILE</label>
            </div>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='compress_block' 
                type='checkbox'
                checked={this.state.object.compress_block || false}
                onChange={this.handleOnChange}
                id='compress_blocks' />
              <label htmlFor='compress_blocks' className='checkbox-label'>Compress blocks</label>
            </div>
            <button className='btn' type='submit'>{this.state.saving ? 'Saving...' : 'Save'}</button>
          </form>
          <h1>Content</h1>
          <ul className='slide-list'>
            {
              this.state.object.items.map(item => {
                return <li key={item.id || randomString()}>
                  <StoreGridItem 
                  key={item.id || randomString()}
                  item={item}
                  removing={this.state.removing}
                  handleUpdateNewItem={this.handleUpdateNewItem}
                  handleRemoveItem={this.handleRemoveItem} />
                </li>
              })
            }
            <div className='add-more-slide pl-3'>
              <button className='btn' type='button' onClick={this.handleAddItem}>Add promotional item</button>
            </div>
          </ul>
        </div>
        <hr></hr>
        <div className='add-more-slide'>
          <button className='btn' type='button' onClick={this.handleRemoveSection}>{this.state.sectionRemoving ? 'Removing...' : 'Remove section'}</button>
        </div>
      </div>
    )
  }
}

StoreGrid.defaultProps = {
  object: {
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

export default connect(mapStateToProps, mapDispatchToProps)(StoreGrid)