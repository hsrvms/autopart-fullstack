import FlutterMacOS
import AppKit

class PrintHandler: NSObject {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example.autoparts/print",
            binaryMessenger: registrar.messenger)
        
        channel.setMethodCallHandler { call, result in
            if call.method == "printBarcode" {
                guard let args = call.arguments as? [String: Any],
                      let templateData = args["templateData"] as? [String: Any],
                      let templateIndex = args["templateIndex"] as? Int else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Geçersiz argümanlar",
                                      details: nil))
                    return
                }
                
                // Yazdırma işlemini başlat
                printBarcode(templateData: templateData, templateIndex: templateIndex, completion: { error in
                    if let error = error {
                        result(FlutterError(code: "PRINT_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                    } else {
                        result(nil)
                    }
                })
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    static func printBarcode(templateData: [String: Any], templateIndex: Int, completion: @escaping (Error?) -> Void) {
        // Yazdırma işlemi için NSPrintOperation oluştur
        let printOperation = NSPrintOperation.shared
        let printInfo = NSPrintInfo.shared
        
        // Sayfa boyutunu ayarla (örnek: 100x50mm barkod etiketi için)
        printInfo.paperSize = NSSize(width: 100, height: 50)
        printInfo.leftMargin = 5
        printInfo.rightMargin = 5
        printInfo.topMargin = 5
        printInfo.bottomMargin = 5
        
        // Yazdırma panelini göster
        let printPanel = NSPrintPanel()
        printPanel.options = [.showsPageSetupAccessory, .showsPrintSelection]
        
        // Yazdırılacak içeriği oluştur
        let printView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 50))
        var yOffset: CGFloat = 45 // Yukarıdan başla
        
        // Şablon tipine göre içerik ekle
        switch templateIndex {
        case 0: // Basit şablon: Sadece barkod ve kod
            addBarcodeAndCode(to: printView, data: templateData, yOffset: &yOffset)
            
        case 1: // Temel şablon: Barkod, kod ve araç bilgileri
            addBarcodeAndCode(to: printView, data: templateData, yOffset: &yOffset)
            addVehicleInfo(to: printView, data: templateData, yOffset: &yOffset)
            
        case 2: // Standart şablon: Barkod, kod, araç bilgileri, OEM ve açıklama
            addBarcodeAndCode(to: printView, data: templateData, yOffset: &yOffset)
            addVehicleInfo(to: printView, data: templateData, yOffset: &yOffset)
            addOEMAndDescription(to: printView, data: templateData, yOffset: &yOffset)
            
        case 3: // Detaylı şablon: Öncekiler + kategori ve parça adı
            addBarcodeAndCode(to: printView, data: templateData, yOffset: &yOffset)
            addVehicleInfo(to: printView, data: templateData, yOffset: &yOffset)
            addOEMAndDescription(to: printView, data: templateData, yOffset: &yOffset)
            addCategoryAndPartInfo(to: printView, data: templateData, yOffset: &yOffset)
            
        case 4: // Tam detay: Tüm bilgiler
            addBarcodeAndCode(to: printView, data: templateData, yOffset: &yOffset)
            addVehicleInfo(to: printView, data: templateData, yOffset: &yOffset)
            addOEMAndDescription(to: printView, data: templateData, yOffset: &yOffset)
            addCategoryAndPartInfo(to: printView, data: templateData, yOffset: &yOffset)
            addStockAndLocation(to: printView, data: templateData, yOffset: &yOffset)
            
        default:
            break
        }
        
        // Yazdırma işlemini başlat
        printOperation.printPanel = printPanel
        printOperation.view = printView
        
        if printOperation.run() {
            completion(nil)
        } else {
            completion(NSError(domain: "PrintError",
                             code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Yazdırma işlemi başarısız oldu"]))
        }
    }
    
    // Helper fonksiyonlar
    private static func addBarcodeAndCode(to view: NSView, data: [String: Any], yOffset: inout CGFloat) {
        let barcode = data["barcode"] as? String ?? ""
        let label = NSTextField(frame: NSRect(x: 10, y: yOffset - 20, width: 80, height: 20))
        label.stringValue = barcode
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        view.addSubview(label)
        yOffset -= 25
    }
    
    private static func addVehicleInfo(to view: NSView, data: [String: Any], yOffset: inout CGFloat) {
        let make = data["make"] as? String ?? ""
        let model = data["model"] as? String ?? ""
        let submodel = data["submodel"] as? String ?? ""
        let yearRange = data["yearRange"] as? String ?? ""
        
        let vehicleInfo = "\(make) \(model) \(submodel) (\(yearRange))"
        let label = NSTextField(frame: NSRect(x: 10, y: yOffset - 20, width: 80, height: 20))
        label.stringValue = vehicleInfo
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        view.addSubview(label)
        yOffset -= 25
    }
    
    private static func addOEMAndDescription(to view: NSView, data: [String: Any], yOffset: inout CGFloat) {
        let oem = data["oem"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        
        let info = "OEM: \(oem)\n\(description)"
        let label = NSTextField(frame: NSRect(x: 10, y: yOffset - 20, width: 80, height: 20))
        label.stringValue = info
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        view.addSubview(label)
        yOffset -= 25
    }
    
    private static func addCategoryAndPartInfo(to view: NSView, data: [String: Any], yOffset: inout CGFloat) {
        let category = data["category"] as? String ?? ""
        let partNumber = data["partNumber"] as? String ?? ""
        
        let info = "Kategori: \(category)\nParça No: \(partNumber)"
        let label = NSTextField(frame: NSRect(x: 10, y: yOffset - 20, width: 80, height: 20))
        label.stringValue = info
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        view.addSubview(label)
        yOffset -= 25
    }
    
    private static func addStockAndLocation(to view: NSView, data: [String: Any], yOffset: inout CGFloat) {
        let stock = data["stock"] as? String ?? ""
        let location = data["location"] as? String ?? ""
        
        let info = "Stok: \(stock)\nKonum: \(location)"
        let label = NSTextField(frame: NSRect(x: 10, y: yOffset - 20, width: 80, height: 20))
        label.stringValue = info
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        view.addSubview(label)
        yOffset -= 25
    }
} 