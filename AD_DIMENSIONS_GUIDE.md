# Ad Dimensions Guide for Designers

This document provides **EXACT FIXED PIXEL DIMENSIONS** for creating startup ads and banners that will display correctly on ALL screen sizes without clipping.

## 📱 Startup Ads (Popup Ads) - FIXED DIMENSIONS

### Exact Pixel Dimensions
- **Width**: `328 pixels` (fixed)
- **Height**: `600 pixels` (fixed)
- **Total Dialog Size**: `328px × 600px`

### Image Area Dimensions
- **Image Width**: `328 pixels` (full width)
- **Image Height**: 
  - **With Header**: `480 pixels` (600px - 120px header)
  - **Without Header**: `600 pixels` (full height)

### Header Area (Optional - if title/description exists)
- **Header Height**: `120 pixels` (fixed)
- **Padding**: 
  - Top: `24px`
  - Left/Right: `20px`
  - Bottom: `20px`
- **Title Font Size**: `20px` (fixed)
- **Description Font Size**: `14px` (fixed)

### Border Radius
- **Dialog Corners**: `28px` (all corners)
- **Image Bottom Corners**: `28px` (bottom-left and bottom-right only)

### Design Specifications
- **Aspect Ratio**: Approximately `0.547:1` (portrait, wider than 3:4)
- **File Format**: PNG or JPG (JPG recommended for smaller file sizes)
- **File Size**: Keep under 500KB for optimal loading performance
- **Resolution**: Design at `328×600px` or `656×1200px` (2x for retina displays)

### Safe Zones
- **Keep important content within**: `20px` from all edges
- **Text in header**: Maximum 2 lines for title, 3 lines for description
- **Critical elements**: Keep within center `280×560px` area

---

## 🎨 Banner Ads (Home Screen Carousel) - FIXED DIMENSIONS

### Exact Pixel Dimensions
- **Width**: `342 pixels` (fixed)
- **Height**: `160 pixels` (fixed)
- **Total Banner Size**: `342px × 160px`

### Image Area Dimensions
- **Image Width**: `342 pixels` (full width)
- **Image Height**: `160 pixels` (full height)

### Aspect Ratio
- **Aspect Ratio**: `2.1375:1` (approximately `16:7.5` or `2.14:1`)

### Border Radius
- **Banner Corners**: `20px` (all corners)

### Overlay Elements
- **Gradient Overlay**: Dark gradient from transparent to 30% black opacity at bottom
- **Title Position**: Bottom, `16px` from edges (left, right, bottom)
- **Title Font Size**: `18px` (fixed)
- **Title Text Shadow**: Black 54% opacity, `2px` offset, `4px` blur

### Design Specifications
- **File Format**: PNG or JPG (JPG recommended for smaller file sizes)
- **File Size**: Keep under 300KB for optimal loading performance
- **Resolution**: Design at `342×160px` or `684×320px` (2x for retina displays)

### Safe Zones
- **Keep important content within**: `16px` from all edges
- **Bottom area (bottom 80px)**: Will have dark gradient overlay - ensure text/elements are visible
- **Critical elements**: Keep within center `310×128px` area

---

## 📊 Screen Size Reference

### Common Mobile Screen Dimensions
- **Small Phones**: 360px × 640px (e.g., older Android devices)
- **Standard Phones**: 375px × 812px (e.g., iPhone X, iPhone 11)
- **Large Phones**: 414px × 896px (e.g., iPhone 11 Pro Max)
- **Extra Large Phones**: 428px × 926px (e.g., iPhone 14 Pro Max)

**Note**: Despite varying screen sizes, ads and banners will ALWAYS display at the fixed dimensions specified above.

---

## ✅ Quality Checklist

Before submitting ads/banners:

- [ ] **Exact dimensions** (Startup Ads: 328×600px, Banners: 342×160px)
- [ ] Important content within safe zones
- [ ] File size under recommended limits
- [ ] High resolution (at least 2x for retina displays = 656×1200px for ads, 684×320px for banners)
- [ ] Text is readable (if included in image)
- [ ] Colors match brand guidelines
- [ ] Tested on multiple screen sizes (preview)

---

## 🎯 Quick Reference Table

| Ad Type | Width (px) | Height (px) | Aspect Ratio | Recommended 2x Size |
|---------|------------|-------------|--------------|---------------------|
| **Startup Ad** | 328 | 600 | 0.547:1 | 656×1200px |
| **Banner** | 342 | 160 | 2.1375:1 | 684×320px |

---

## 📝 Important Notes for Developers

- All dimensions are **FIXED PIXEL VALUES** - not responsive
- Images use `BoxFit.cover` to fill the entire space
- Both startup ads and banners will display at these exact dimensions on ALL screen sizes
- The aspect ratio is strictly enforced - images with different ratios will be cropped to fit
- Dialog padding: 16px horizontal, 40px vertical (for startup ads)
- Banner carousel viewport: 95% of screen width, but banner itself is fixed at 342px width

---

## 🎨 Design Tips

1. **For Startup Ads (328×600px)**:
   - Design in portrait orientation
   - Keep important content in the center 280×560px area
   - If using header, reserve top 120px for title/description
   - Image area is 328×480px (with header) or 328×600px (without header)

2. **For Banners (342×160px)**:
   - Design in wide landscape orientation
   - Keep important content in the center 310×128px area
   - Bottom 80px will have dark gradient overlay - ensure contrast
   - If using title overlay, position text in bottom 16px margin

3. **Color Considerations**:
   - Startup ad header uses light blue tint (10% opacity of primary color)
   - Banner has dark gradient overlay at bottom (30% black opacity)
   - Ensure text and important elements have sufficient contrast
