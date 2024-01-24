import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var names = [String]()
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lista de Epstein"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        //Recuperar las personas de CoreData
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addNameBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Nuevo nombre", message: "Añade un nombre", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Añadir", style: .default){ (action) -> Void in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            //self.names.append(nameToSave)
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        let cancerAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancerAction)
        present(alert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(name, forKeyPath: "name")
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError{
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell.textLabel?.text = names[indexPath.row]
        let person = people[indexPath.row]
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
}
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Editar un elemento
        let editAction = UIContextualAction(style: .normal, title: "Editar"){ (action, view, completioHandler) in
            //Obtener la instancia correspondiente a la celda
            let person = self.people[indexPath.row]
            //Funcion para editar un registro
            self.alertEditar(person: person)
        }
        //Eliminar
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar"){ (action, view, completionHandler) in
            let person = self.people[indexPath.row]
            //Eliminar instancia del contexto CoreData
            let managedContext = person.managedObjectContext
            managedContext?.delete(person)
            //Guardamos los cambios
            do{
                try managedContext?.save()
            } catch let error as NSError {
                print("Delete Error : \(error), \(error.userInfo)")
            }
            //Eliminar la instancia del array
            self.people.remove(at: indexPath.row)
            //Reload
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .systemRed
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        
    }
    func alertEditar(person: NSManagedObject){
        let alert = UIAlertController(title: "Modificar nombre", message: "Añade un nombre", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Confirmar", style: .default){ (action) -> Void in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            person.setValue(nameToSave, forKey: "name")
            do{
                try person.managedObjectContext?.save()
            } catch let error as NSError{
                print("Edit error: \(error), \(error.userInfo)")
            }
            self.tableView.reloadData()
        }
        let cancerAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancerAction)
        present(alert, animated: true)
    }
}
