using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClickSelection : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0)){
            clickToSelect();
        }
    }


    /// Selects unit if it is under the left mouse click, deselected all units that are not under a mouse click.
    void clickToSelect(){
        GameObject playerUnits = GameObject.FindWithTag("PlayerUnits");
        Component[] playerUnitControllers = playerUnits.GetComponentsInChildren(typeof(UnitController));
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        foreach(UnitController unitController in playerUnitControllers){
            UnitAgent[] unitAgents = getUnitAgents(unitController);
            bool unitUnderClick = false;
            if (Physics.Raycast(ray, out hit)){
                foreach(UnitAgent agent in unitAgents){
                    Transform agentTransform = agent.transform;
                    if(hit.transform == agentTransform){
                        unitUnderClick = true;
                        break;
                    }
                }
            }

            if(unitUnderClick && !unitController.isUnitSelected()){
                Debug.Log("CS - select");
                unitController.setUnitState("selected");
            }
            // else if(unitUnderClick && unitController.isUnitSelected()){
            //     Debug.Log("CS - deselect 1");
            //     unitController.setUnitState("deselected");
            // }
            else{
                Debug.Log("CS - deselect 2");
                unitController.setUnitState("deselected");
            }
        }
    }

    /// Gets the unit agents from a given agent controller
    /// <param name"unitController"> The UnitController to get the agents from. </param>
    private UnitAgent[] getUnitAgents(UnitController unitController){
        GameObject[] agents = unitController.getAgents();
        UnitAgent[] unitAgents = new UnitAgent[agents.Length];
        for(int i = 0; i < agents.Length; i++){
            unitAgents[i] = agents[i].GetComponent<UnitAgent>();
        }
        return unitAgents;
    }
}
