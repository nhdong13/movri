import React, { Component } from 'react'
import { sectionData } from './data'
import StoreCategoryList from '../StoreCategoryList'

class SectionMore extends Component {
  constructor(props) {
    super(props)
    this.state = {
      currentSection: undefined
    }

    this.setCurrentSection = this.setCurrentSection.bind(this)
  }

  setCurrentSection(modelName) {
    this.setState({currentSection: modelName})
  }


  renderContent() {
    const { currentSection } = this.state
    switch(currentSection) {
      case 'CollectionList':
        return <StoreCategoryList callback={this.setCurrentSection} />
      default:
        return (
          <div className='store-header add-more-section'>
            <div className='breabcrum' onClick={this.props.closeMoreSection}>
              <i className="icon-chevron-left"></i>
              <span>Add section</span>
            </div>
            <div className='section-main-content'>
              {
                sectionData.map(ct => {
                  return (<div className='section-category' key={ct.categoryName}>
                    <div className='category-name p-2'>{ct.categoryName}</div>
                    <div className='section-list-s'>
                      { ct.items.map(item => {
                        return <div className='p-2 section-item' key={item.name} onClick={() => this.setCurrentSection(item.model)}>{item.name}</div>
                      })}
                    </div>
                  </div>)
                })
              }
            </div>
          </div>
        )
    }
  }

  render() {
    return(
      <div>
        { this.renderContent() }
      </div>
    )
  }
}

export default SectionMore