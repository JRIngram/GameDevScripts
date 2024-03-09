using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoxSelection : MonoBehaviour
{
    /// The SelectionBox 
    public RectTransform selectionBox;

    /// Position of the mouse on screen when drawing the selection box
    private Vector2 startPos;

    /// The time the left mouse button should be held down prior to drawing the selection box
    private float delayBeforeCreatingBox;


    /// The time the mouse has been held down for
    private float createBoxTimer;


    /// If the selection box should be drawn or not
    private bool createBox;



    void Start()
    {
        delayBeforeCreatingBox = .15f;
        createBoxTimer = 0.0f;
        createBox = false;
    }

    void Update()
    {   
        if(Input.GetMouseButton(0) && !createBox){
            createBoxTimer += Time.deltaTime;
        }

        if(createBoxTimer > delayBeforeCreatingBox){
            createBox = true;
        }

        if(Input.GetMouseButtonDown(0)){
            startPos = Input.mousePosition;
        }

        if(createBox){
            if(Input.GetMouseButton(0)){
                UpdateSelectionBox(Input.mousePosition);
            }
            else if(Input.GetMouseButtonUp(0)){
                ReleaseSelectionBox();
                createBoxTimer = 0.0f;
                createBox = false;
            }
        }
    }

    /// Updates the bounds of the selection box and draws onto the screen
    /// <param name="currentMousePosition">The current position of the mouse </param>
    void UpdateSelectionBox (Vector2 currentMousePosition)
    {
        if(!selectionBox.gameObject.activeInHierarchy)
            selectionBox.gameObject.SetActive(true);
    
        float width = currentMousePosition.x - startPos.x;
        float height = currentMousePosition.y - startPos.y;
    
        selectionBox.sizeDelta = new Vector2(Mathf.Abs(width), Mathf.Abs(height));
        selectionBox.anchoredPosition = startPos + new Vector2(width / 2, height / 2);
    }


    /// Sets UnitController states to selected or deselected depending on if the UnitControllers are below the selection box
    void ReleaseSelectionBox(){
        selectionBox.gameObject.SetActive(false);

        Vector2 min = selectionBox.anchoredPosition - (selectionBox.sizeDelta / 2);
        Vector2 max = selectionBox.anchoredPosition + (selectionBox.sizeDelta / 2);

        GameObject playerUnits = GameObject.FindWithTag("PlayerUnits");
        Component[] playerUnitControllers = playerUnits.GetComponentsInChildren(typeof(UnitController));


        foreach(UnitController unitController in playerUnitControllers){
            GameObject[] agents = unitController.getAgents();
            bool selectUnit = false;
            foreach(GameObject agent in agents){
                Vector3 agentScreenPosition = Camera.main.WorldToScreenPoint(agent.transform.position);
                if(agentScreenPosition.x > min.x && agentScreenPosition.x < max.x && agentScreenPosition.y > min.y && agentScreenPosition.y < max.y)
                {
                    selectUnit = true;
                    break;
                }
            }
            if(selectUnit){
                Debug.Log("BS - select");
                unitController.setUnitState("selected");
            }
            else{
                Debug.Log("BS - deselect");
                unitController.setUnitState("deselected");
            }
            
        }
    }
}
